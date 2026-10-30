import Foundation
import AVFoundation

/// Production implementation of hardware video capture engine using AVFoundation.
/// Dispatches incoming frame buffers on a private background queue to maintain fluid 60fps UI.
final class CameraService: NSObject, CameraServiceProtocol {

    let captureSession = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.teayield.camera.sessionQueue")
    private let cameraDataOutput = AVCaptureVideoDataOutput()
    private var frameHandler: ((CVPixelBuffer) -> Void)?
    private var isConfigured = false

    private(set) var isRunning: Bool = false

    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    override init() {
        super.init()
    }

    /// Asynchronously requests camera authorization from the iOS system.
    func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    /// Starts streaming video frames on the private session queue.
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.isConfigured {
                self.configureSession()
            }
            guard !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
            self.isRunning = self.captureSession.isRunning
        }
    }

    /// Halts active frame capture to conserve device battery and thermal limits in field estates.
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
            self.isRunning = false
        }
    }

    /// Registers a closure invoked on each incoming frame pixel buffer.
    func setFrameHandler(_ handler: @escaping (CVPixelBuffer) -> Void) {
        self.frameHandler = handler
    }

    // MARK: - Hardware Configuration

    private func configureSession() {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // 720p delivers optimal sharpness for shoot trichomes while preserving 60fps throughput
        if captureSession.canSetSessionPreset(.hd1280x720) {
            captureSession.sessionPreset = .hd1280x720
        } else {
            captureSession.sessionPreset = .high
        }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            // Running in Simulator or device lacking physical camera
            isConfigured = true
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            cameraDataOutput.alwaysDiscardsLateVideoFrames = true
            cameraDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            cameraDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)

            if captureSession.canAddOutput(cameraDataOutput) {
                captureSession.addOutput(cameraDataOutput)
            }

            // Fix video orientation to portrait matching mobile estate usage
            if let connection = cameraDataOutput.connection(with: .video), connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }

            isConfigured = true
        } catch {
            isConfigured = false
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {

    /// Dispatches video sample frames to the Vision inference pipeline.
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        frameHandler?(pixelBuffer)
    }
}

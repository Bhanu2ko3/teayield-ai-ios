import Foundation
import AVFoundation
import CoreVideo
@testable import TeaYieldAI

/// Test double simulating AVFoundation camera hardware capture session.
final class MockCameraService: CameraServiceProtocol {

    let captureSession: AVCaptureSession = AVCaptureSession()
    var isRunning: Bool = false
    var isAuthorized: Bool = true
    var permissionToReturn: Bool = true

    private(set) var startSessionCallCount: Int = 0
    private(set) var stopSessionCallCount: Int = 0
    private(set) var requestPermissionCallCount: Int = 0

    private var frameHandler: ((CVPixelBuffer) -> Void)?

    func requestPermission() async -> Bool {
        requestPermissionCallCount += 1
        return permissionToReturn
    }

    func startSession() {
        startSessionCallCount += 1
        isRunning = true
    }

    func stopSession() {
        stopSessionCallCount += 1
        isRunning = false
    }

    func setFrameHandler(_ handler: @escaping (CVPixelBuffer) -> Void) {
        self.frameHandler = handler
    }

    /// Feeds a synthetic or dummy pixel buffer directly into the pipeline to test inference triggering.
    func simulateIncomingFrame(_ pixelBuffer: CVPixelBuffer) {
        frameHandler?(pixelBuffer)
    }
}

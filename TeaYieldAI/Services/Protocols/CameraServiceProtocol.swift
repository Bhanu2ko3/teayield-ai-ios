import Foundation
import AVFoundation

/// Defines the contract for hardware camera capture and frame buffer streaming.
protocol CameraServiceProtocol: AnyObject {

    /// Active capture session driving video input and preview layers.
    var captureSession: AVCaptureSession { get }

    /// Indicates whether video capture is actively streaming frames.
    var isRunning: Bool { get }

    /// Indicates whether the user has authorized camera hardware access.
    var isAuthorized: Bool { get }

    /// Requests camera capture permissions asynchronously from the user.
    func requestPermission() async -> Bool

    /// Starts streaming video frames on a dedicated background queue.
    func startSession()

    /// Halts active frame capture to preserve device battery in mountain estates.
    func stopSession()

    /// Registers a closure invoked on each captured video frame buffer.
    func setFrameHandler(_ handler: @escaping (CVPixelBuffer) -> Void)
}

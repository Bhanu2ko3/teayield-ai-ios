import Foundation
import CoreVideo
import CoreGraphics

/// Defines the contract for offline tea shoot maturity inference using Apple Vision and Core ML.
protocol VisionLeafClassifierProtocol: AnyObject {

    /// Classifies an uncompressed live camera frame pixel buffer on the Apple Silicon Neural Engine.
    func classify(pixelBuffer: CVPixelBuffer) async throws -> LeafQualityAssessment

    /// Classifies a static image selected from the device photo library or test bundle.
    func classify(image: CGImage) async throws -> LeafQualityAssessment
}

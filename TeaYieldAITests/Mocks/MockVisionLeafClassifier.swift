import Foundation
import CoreVideo
import CoreGraphics
@testable import TeaYieldAI

/// Test double simulating Apple Vision Neural Engine inference.
final class MockVisionLeafClassifier: VisionLeafClassifierProtocol {

    var stubbedAssessment: LeafQualityAssessment?
    var shouldThrowError: Bool = false
    var errorToThrow: Error = NSError(
        domain: "TeaYieldAI.Vision",
        code: 101,
        userInfo: [NSLocalizedDescriptionKey: "Simulated Vision model failure"]
    )

    private(set) var classifyPixelBufferCallCount: Int = 0
    private(set) var classifyImageCallCount: Int = 0

    init(stubbedAssessment: LeafQualityAssessment? = nil) {
        self.stubbedAssessment = stubbedAssessment
    }

    func classify(pixelBuffer: CVPixelBuffer) async throws -> LeafQualityAssessment {
        classifyPixelBufferCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        if let assessment = stubbedAssessment {
            return assessment
        }
        return LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.94,
            fineLeafRatio: 0.88,
            coarseLeafRatio: 0.12,
            maturityProbabilities: [
                "Two Leaves & Bud": 0.88,
                "Coarse Foliage": 0.12
            ],
            inferenceLatencyMs: 14.2,
            timestamp: Date()
        )
    }

    func classify(image: CGImage) async throws -> LeafQualityAssessment {
        classifyImageCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        if let assessment = stubbedAssessment {
            return assessment
        }
        return LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.96,
            fineLeafRatio: 0.91,
            coarseLeafRatio: 0.09,
            maturityProbabilities: [
                "Two Leaves & Bud": 0.91,
                "Coarse Foliage": 0.09
            ],
            inferenceLatencyMs: 16.5,
            timestamp: Date()
        )
    }
}

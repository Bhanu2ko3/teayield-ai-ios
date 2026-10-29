import Foundation
import CoreML
import Vision
import CoreVideo
import CoreGraphics
import Darwin

/// Domain errors encountered during edge Vision & Core ML inference.
enum VisionClassifierError: LocalizedError {
    case modelNotFound
    case modelCompilationFailed(String)
    case inferenceFailed(String)
    case invalidObservationResults

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Tea shoot classification CoreML model bundle artifact was not found."
        case .modelCompilationFailed(let reason):
            return "Failed to compile CoreML model on device: \(reason)"
        case .inferenceFailed(let reason):
            return "Apple Silicon Vision inference failed: \(reason)"
        case .invalidObservationResults:
            return "Model returned unexpected observation format from Vision request."
        }
    }
}

/// Production implementation of on-device tea shoot maturity classifier.
/// Runs 100% offline on the Apple Silicon Neural Engine via Apple Vision & Core ML.
final class VisionLeafClassifier: VisionLeafClassifierProtocol, @unchecked Sendable {

    private var vnModel: VNCoreMLModel?
    private let initializationQueue = DispatchQueue(label: "com.teayield.classifier.initQueue", qos: .userInitiated)

    init() {
        loadModel()
    }

    // MARK: - Model Lifecycle

    private func loadModel() {
        initializationQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let model = try self.resolveAndCompileModel()
                let visionModel = try self.createVisionModelSilencingDiagnostics(for: model)
                self.vnModel = visionModel
            } catch {
                // Handled gracefully during inference attempts
                self.vnModel = nil
            }
        }
    }

    /// Creates a VNCoreMLModel while silencing internal CoreML evaluation parameter notices from the console.
    private func createVisionModelSilencingDiagnostics(for model: MLModel) throws -> VNCoreMLModel {
        fflush(stderr)
        let savedStderr = dup(STDERR_FILENO)
        let devNull = open("/dev/null", O_WRONLY)
        if devNull >= 0 {
            dup2(devNull, STDERR_FILENO)
            close(devNull)
        }

        defer {
            fflush(stderr)
            dup2(savedStderr, STDERR_FILENO)
            close(savedStderr)
        }

        let visionModel = try VNCoreMLModel(for: model)
        visionModel.featureProvider = nil
        return visionModel
    }

    private func resolveAndCompileModel() throws -> MLModel {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all // Leverages Neural Engine, GPU, and CPU

        // Check for v2 optimized model first, then v1 baseline fallback
        let candidateNames = ["TeaShootClassifier_v2", "TeaShootClassifier"]

        for name in candidateNames {
            if let compiledURL = Bundle.main.url(forResource: name, withExtension: "mlmodelc") {
                return try MLModel(contentsOf: compiledURL, configuration: configuration)
            }
            if let rawModelURL = Bundle.main.url(forResource: name, withExtension: "mlmodel") {
                let compiledURL = try MLModel.compileModel(at: rawModelURL)
                return try MLModel(contentsOf: compiledURL, configuration: configuration)
            }
        }

        throw VisionClassifierError.modelNotFound
    }

    // MARK: - Inference Execution

    func classify(pixelBuffer: CVPixelBuffer) async throws -> LeafQualityAssessment {
        let model = try await getOrInitializeModel()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        return try await performInference(handler: handler, model: model)
    }

    func classify(image: CGImage) async throws -> LeafQualityAssessment {
        let model = try await getOrInitializeModel()
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        return try await performInference(handler: handler, model: model)
    }

    private func getOrInitializeModel() async throws -> VNCoreMLModel {
        if let existing = vnModel {
            return existing
        }
        return try await withCheckedThrowingContinuation { continuation in
            initializationQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: VisionClassifierError.modelNotFound)
                    return
                }
                do {
                    let raw = try self.resolveAndCompileModel()
                    let visionModel = try self.createVisionModelSilencingDiagnostics(for: raw)
                    self.vnModel = visionModel
                    continuation.resume(returning: visionModel)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func performInference(handler: VNImageRequestHandler, model: VNCoreMLModel) async throws -> LeafQualityAssessment {
        let startTime = CFAbsoluteTimeGetCurrent()

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    continuation.resume(throwing: VisionClassifierError.inferenceFailed(error.localizedDescription))
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation], !observations.isEmpty else {
                    continuation.resume(throwing: VisionClassifierError.invalidObservationResults)
                    return
                }

                let elapsedMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0
                let assessment = self.processObservations(observations, latencyMs: elapsedMs)
                continuation.resume(returning: assessment)
            }

            request.imageCropAndScaleOption = .centerCrop

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: VisionClassifierError.inferenceFailed(error.localizedDescription))
            }
        }
    }

    // MARK: - Observations Processing

    private func processObservations(_ observations: [VNClassificationObservation], latencyMs: Double) -> LeafQualityAssessment {
        var rawProbabilities: [String: Double] = [:]
        for obs in observations {
            rawProbabilities[obs.identifier] = Double(obs.confidence)
        }

        // Apply numerically stable Softmax normalization in case model outputs raw logits
        let normalized = normalizeToProbabilities(rawProbabilities)

        // Extract native 4-class probabilities
        let pT1 = normalized["1-2 Days"] ?? 0.0
        let pT2 = normalized["3-4 Days"] ?? 0.0
        let pT3 = normalized["5-7 Days"] ?? 0.0
        let pT4 = normalized["7+ Days"] ?? 0.0

        // Composite Fine Leaf Aggregation benchmarked against Sri Lanka Tea Board 85% standard
        let fineLeaf = pT1 + pT2
        let coarseLeaf = pT3 + pT4

        // Identify dominant maturity stage (highest probability class)
        let topClass = normalized.max(by: { $0.value < $1.value })?.key ?? observations[0].identifier
        let dominantStage = LeafMaturityStage(rawValue: topClass) ?? .primeTwoLeaves
        let topConfidence = normalized[topClass] ?? Double(observations[0].confidence)

        return LeafQualityAssessment(
            dominantStage: dominantStage,
            confidence: topConfidence,
            fineLeafRatio: min(max(fineLeaf, 0.0), 1.0),
            coarseLeafRatio: min(max(coarseLeaf, 0.0), 1.0),
            maturityProbabilities: normalized,
            inferenceLatencyMs: latencyMs,
            timestamp: Date()
        )
    }

    /// Normalizes output logits to valid [0.0, 1.0] probabilities via numerically stable Softmax.
    private func normalizeToProbabilities(_ rawDict: [String: Double]) -> [String: Double] {
        let values = Array(rawDict.values)
        let hasNegatives = values.contains { $0 < 0 }
        let sum = values.reduce(0.0, +)
        let isAlreadyProbabilities = !hasNegatives && abs(sum - 1.0) < 0.05

        if isAlreadyProbabilities {
            return rawDict.mapValues { min(max($0, 0.0), 1.0) }
        }

        // Numerically stable Softmax: exp(z_i - max(z))
        let maxVal = values.max() ?? 0.0
        var expDict: [String: Double] = [:]
        var expSum: Double = 0.0

        for (key, val) in rawDict {
            let expVal = exp(val - maxVal)
            expDict[key] = expVal
            expSum += expVal
        }

        guard expSum > 0 else { return rawDict }
        return expDict.mapValues { $0 / expSum }
    }
}

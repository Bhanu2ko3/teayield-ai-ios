import Foundation
import UIKit
import CoreVideo
import CoreGraphics
import Combine

/// Display mode for leaf maturity evaluation.
enum LeafScanMode: String, CaseIterable, Identifiable {
    case liveCamera = "Live Viewfinder"
    case photoLibrary = "Inspection Gallery"

    var id: String { rawValue }
}

/// Primary ViewModel driving on-device leaf quality scanning, live HUD gauges, and PhotosUI analysis.
/// Strictly conforms to Xcode 14.3.1 / iOS 16.4 baseline using ObservableObject and @MainActor.
@MainActor
final class LeafScannerViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var assessment: LeafQualityAssessment?
    @Published var fineLeafRatio: Double = 0.0
    @Published var smoothedFineLeafRatio: Double = 0.0
    @Published var qualityGrade: String = "READY TO SCAN"
    @Published var isOptimalHarvest: Bool = false
    @Published var inferenceTimeMs: Double = 0.0
    @Published var isCameraRunning: Bool = false
    @Published var hasCameraPermission: Bool = true
    @Published var scanMode: LeafScanMode = .liveCamera

    @Published var selectedImage: UIImage? = nil
    @Published var selectedImages: [UIImage] = []
    @Published var selectedBatchIndex: Int = 0
    @Published var batchAssessments: [(image: UIImage, assessment: LeafQualityAssessment)] = []
    @Published var batchAverageFineLeafRatio: Double = 0.0
    @Published var isAnalyzingPhoto: Bool = false
    @Published var frameSampleCount: Int = 0
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies

    let cameraService: CameraServiceProtocol
    let classifier: VisionLeafClassifierProtocol

    // MARK: - Private State

    private var isProcessingFrame = false
    private var lastInferenceTimestamp: TimeInterval = 0
    private let minimumInferenceInterval: TimeInterval = 0.08 // Throttle to ~12fps on NPU to preserve battery
    private var sampleBufferQueue: [Double] = []
    private let maxSmoothingWindow = 15

    // MARK: - Initialization

    init(
        cameraService: CameraServiceProtocol = CameraService(),
        classifier: VisionLeafClassifierProtocol = VisionLeafClassifier()
    ) {
        self.cameraService = cameraService
        self.classifier = classifier
        setupFramePipeline()
    }

    // MARK: - Lifecycle Management

    /// Initializes hardware camera permissions and starts live streaming when active.
    func onAppear() {
        Task {
            let granted = await cameraService.requestPermission()
            self.hasCameraPermission = granted
            if granted && scanMode == .liveCamera {
                startScanning()
            }
        }
    }

    /// Halts camera capture when navigating away to preserve field battery life.
    func onDisappear() {
        stopScanning()
    }

    func startScanning() {
        cameraService.startSession()
        isCameraRunning = true
    }

    func stopScanning() {
        cameraService.stopSession()
        isCameraRunning = false
    }

    func switchScanMode(_ mode: LeafScanMode) {
        self.scanMode = mode
        if mode == .liveCamera {
            selectedImage = nil
            startScanning()
        } else {
            stopScanning()
        }
    }

    // MARK: - Frame Processing Pipeline

    private func setupFramePipeline() {
        cameraService.setFrameHandler { [weak self] pixelBuffer in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.handleIncomingFrame(pixelBuffer)
            }
        }
    }

    private func handleIncomingFrame(_ pixelBuffer: CVPixelBuffer) {
        guard scanMode == .liveCamera else { return }

        // Throttle inference rate to prevent battery drain while preserving fluid preview
        let now = Date().timeIntervalSince1970
        guard !isProcessingFrame, (now - lastInferenceTimestamp) >= minimumInferenceInterval else {
            return
        }

        isProcessingFrame = true
        lastInferenceTimestamp = now

        Task {
            do {
                let result = try await classifier.classify(pixelBuffer: pixelBuffer)
                self.applyAssessment(result)
            } catch {
                // Silently drop intermittent frames to maintain 60fps viewfinder stability
            }
            self.isProcessingFrame = false
        }
    }

    // MARK: - Static Photo Inspection (PhotosUI / Test Images)

    /// Analyzes a single high-resolution photograph.
    func analyzeSelectedImage(_ image: UIImage) {
        analyzeBatchImages([image])
    }

    /// Analyzes multiple high-resolution photographs concurrently using Apple Neural Engine.
    func analyzeBatchImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }

        self.selectedImages = images
        self.selectedBatchIndex = 0
        self.selectedImage = images.first
        self.isAnalyzingPhoto = true
        self.errorMessage = nil
        self.batchAssessments = []

        Task {
            var results: [(image: UIImage, assessment: LeafQualityAssessment)] = []

            for img in images {
                guard let cgImage = img.cgImage else { continue }
                if let assessed = try? await classifier.classify(image: cgImage) {
                    results.append((image: img, assessment: assessed))
                }
            }

            self.batchAssessments = results

            if let first = results.first {
                self.applyAssessment(first.assessment)
            }

            // Compute aggregate quality ratio across all batch samples
            if !results.isEmpty {
                let sumRatio = results.reduce(0.0) { $0 + $1.assessment.fineLeafRatio }
                self.batchAverageFineLeafRatio = sumRatio / Double(results.count)
            } else {
                self.batchAverageFineLeafRatio = 0.0
                self.errorMessage = "Unable to classify selected shoot images."
            }

            self.isAnalyzingPhoto = false
        }
    }

    /// Selects an inspected shoot from the batch carousel to view detailed assessment.
    func selectBatchItem(at index: Int) {
        guard index >= 0 && index < batchAssessments.count else { return }
        self.selectedBatchIndex = index
        let item = batchAssessments[index]
        self.selectedImage = item.image
        self.applyAssessment(item.assessment)
    }

    // MARK: - Telemetry Aggregation

    private func applyAssessment(_ result: LeafQualityAssessment) {
        self.assessment = result
        self.fineLeafRatio = result.fineLeafRatio
        self.qualityGrade = result.qualityGrade
        self.isOptimalHarvest = result.meetsExportQuality
        self.inferenceTimeMs = result.inferenceLatencyMs
        self.frameSampleCount += 1

        // Rolling exponential smoothing for HUD gauge stability across heap scans
        sampleBufferQueue.append(result.fineLeafRatio)
        if sampleBufferQueue.count > maxSmoothingWindow {
            sampleBufferQueue.removeFirst()
        }
        let rollingAverage = sampleBufferQueue.reduce(0.0, +) / Double(sampleBufferQueue.count)
        self.smoothedFineLeafRatio = rollingAverage
    }

    /// Resets continuous accumulation statistics for a new plucker bag inspection.
    func resetScan() {
        sampleBufferQueue.removeAll()
        frameSampleCount = 0
        assessment = nil
        fineLeafRatio = 0.0
        smoothedFineLeafRatio = 0.0
        qualityGrade = "READY TO SCAN"
        isOptimalHarvest = false
        inferenceTimeMs = 0.0
        selectedImage = nil
        errorMessage = nil
    }
}

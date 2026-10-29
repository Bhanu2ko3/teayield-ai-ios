import Foundation
import UIKit
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Leaf Scanner ViewModel Unit Tests")
@MainActor
struct LeafScannerViewModelTests {

    @Test("Verifies initial baseline state of the scanner view model")
    func initialState() {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        #expect(viewModel.fineLeafRatio == 0.0)
        #expect(viewModel.smoothedFineLeafRatio == 0.0)
        #expect(viewModel.qualityGrade == "READY TO SCAN")
        #expect(viewModel.isOptimalHarvest == false)
        #expect(viewModel.isCameraRunning == false)
        #expect(viewModel.scanMode == .liveCamera)
        #expect(viewModel.frameSampleCount == 0)
        #expect(viewModel.selectedImage == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Verifies scan mode switching toggles hardware camera session")
    func modeSwitching() {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        viewModel.switchScanMode(.photoLibrary)
        #expect(viewModel.scanMode == .photoLibrary)
        #expect(viewModel.isCameraRunning == false)
        #expect(camera.stopSessionCallCount == 1)

        viewModel.switchScanMode(.liveCamera)
        #expect(viewModel.scanMode == .liveCamera)
        #expect(viewModel.isCameraRunning == true)
        #expect(camera.startSessionCallCount == 1)
    }

    @Test("Verifies image analysis with Grade A optimal harvest ratio")
    func photoAnalysisOptimal() async {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.95,
            fineLeafRatio: 0.92,
            coarseLeafRatio: 0.08,
            maturityProbabilities: ["Two Leaves & Bud": 0.92, "Coarse Foliage": 0.08],
            inferenceLatencyMs: 15.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        // Create a synthetic 1x1 test UIImage
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.green.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)

        // Yield to allow async classification task to complete
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.fineLeafRatio == 0.92)
        #expect(viewModel.isOptimalHarvest == true)
        #expect(viewModel.qualityGrade == "GRADE A - OPTIMAL")
        #expect(viewModel.frameSampleCount == 1)
        #expect(viewModel.isAnalyzingPhoto == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Verifies image analysis with Grade B sub-optimal ratio")
    func photoAnalysisSubOptimal() async {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .maturingLeaves,
            confidence: 0.88,
            fineLeafRatio: 0.74,
            coarseLeafRatio: 0.26,
            maturityProbabilities: ["Maturing Shoot": 0.74, "Coarse Foliage": 0.26],
            inferenceLatencyMs: 14.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.fineLeafRatio == 0.74)
        #expect(viewModel.isOptimalHarvest == false)
        #expect(viewModel.qualityGrade == "GRADE B - SUB-OPTIMAL")
    }

    @Test("Verifies image analysis with Grade C high coarse content rejection")
    func photoAnalysisHighCoarseRejection() async {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .coarseFoliage,
            confidence: 0.91,
            fineLeafRatio: 0.55,
            coarseLeafRatio: 0.45,
            maturityProbabilities: ["Coarse Foliage": 0.45, "Two Leaves": 0.55],
            inferenceLatencyMs: 16.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.fineLeafRatio == 0.55)
        #expect(viewModel.isOptimalHarvest == false)
        #expect(viewModel.qualityGrade == "GRADE C - HIGH COARSE CONTENT")
    }

    @Test("Verifies resetScan clears all accumulated telemetry and state")
    func resetScan() async {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.95,
            fineLeafRatio: 0.90,
            coarseLeafRatio: 0.10,
            maturityProbabilities: [:],
            inferenceLatencyMs: 15.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.fineLeafRatio > 0)

        viewModel.resetScan()

        #expect(viewModel.fineLeafRatio == 0.0)
        #expect(viewModel.smoothedFineLeafRatio == 0.0)
        #expect(viewModel.qualityGrade == "READY TO SCAN")
        #expect(viewModel.isOptimalHarvest == false)
        #expect(viewModel.frameSampleCount == 0)
        #expect(viewModel.selectedImage == nil)
    }

    @Test("Verifies classifier error handling sets user-facing error message")
    func classifierFailure() async {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        classifier.shouldThrowError = true
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isAnalyzingPhoto == false)
    }
}

#else
import XCTest

@MainActor
final class LeafScannerViewModelTests: XCTestCase {

    func testInitialState() {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        XCTAssertEqual(viewModel.fineLeafRatio, 0.0)
        XCTAssertEqual(viewModel.smoothedFineLeafRatio, 0.0)
        XCTAssertEqual(viewModel.qualityGrade, "READY TO SCAN")
        XCTAssertFalse(viewModel.isOptimalHarvest)
        XCTAssertFalse(viewModel.isCameraRunning)
        XCTAssertEqual(viewModel.scanMode, .liveCamera)
        XCTAssertEqual(viewModel.frameSampleCount, 0)
        XCTAssertNil(viewModel.selectedImage)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testModeSwitching() {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        viewModel.switchScanMode(.photoLibrary)
        XCTAssertEqual(viewModel.scanMode, .photoLibrary)
        XCTAssertFalse(viewModel.isCameraRunning)
        XCTAssertEqual(camera.stopSessionCallCount, 1)

        viewModel.switchScanMode(.liveCamera)
        XCTAssertEqual(viewModel.scanMode, .liveCamera)
        XCTAssertTrue(viewModel.isCameraRunning)
        XCTAssertEqual(camera.startSessionCallCount, 1)
    }

    func testPhotoAnalysisOptimal() async throws {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.95,
            fineLeafRatio: 0.92,
            coarseLeafRatio: 0.08,
            maturityProbabilities: ["Two Leaves & Bud": 0.92, "Coarse Foliage": 0.08],
            inferenceLatencyMs: 15.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.green.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.fineLeafRatio, 0.92)
        XCTAssertTrue(viewModel.isOptimalHarvest)
        XCTAssertEqual(viewModel.qualityGrade, "GRADE A - OPTIMAL")
        XCTAssertEqual(viewModel.frameSampleCount, 1)
        XCTAssertFalse(viewModel.isAnalyzingPhoto)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testPhotoAnalysisSubOptimal() async throws {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .maturingLeaves,
            confidence: 0.88,
            fineLeafRatio: 0.74,
            coarseLeafRatio: 0.26,
            maturityProbabilities: ["Maturing Shoot": 0.74, "Coarse Foliage": 0.26],
            inferenceLatencyMs: 14.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.fineLeafRatio, 0.74)
        XCTAssertFalse(viewModel.isOptimalHarvest)
        XCTAssertEqual(viewModel.qualityGrade, "GRADE B - SUB-OPTIMAL")
    }

    func testPhotoAnalysisHighCoarseRejection() async throws {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .coarseFoliage,
            confidence: 0.91,
            fineLeafRatio: 0.55,
            coarseLeafRatio: 0.45,
            maturityProbabilities: ["Coarse Foliage": 0.45, "Two Leaves": 0.55],
            inferenceLatencyMs: 16.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.fineLeafRatio, 0.55)
        XCTAssertFalse(viewModel.isOptimalHarvest)
        XCTAssertEqual(viewModel.qualityGrade, "GRADE C - HIGH COARSE CONTENT")
    }

    func testResetScan() async throws {
        let camera = MockCameraService()
        let assessment = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.95,
            fineLeafRatio: 0.90,
            coarseLeafRatio: 0.10,
            maturityProbabilities: [:],
            inferenceLatencyMs: 15.0,
            timestamp: Date()
        )
        let classifier = MockVisionLeafClassifier(stubbedAssessment: assessment)
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertGreaterThan(viewModel.fineLeafRatio, 0.0)

        viewModel.resetScan()

        XCTAssertEqual(viewModel.fineLeafRatio, 0.0)
        XCTAssertEqual(viewModel.smoothedFineLeafRatio, 0.0)
        XCTAssertEqual(viewModel.qualityGrade, "READY TO SCAN")
        XCTAssertFalse(viewModel.isOptimalHarvest)
        XCTAssertEqual(viewModel.frameSampleCount, 0)
        XCTAssertNil(viewModel.selectedImage)
    }

    func testClassifierFailure() async throws {
        let camera = MockCameraService()
        let classifier = MockVisionLeafClassifier()
        classifier.shouldThrowError = true
        let viewModel = LeafScannerViewModel(cameraService: camera, classifier: classifier)

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let testImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        viewModel.analyzeSelectedImage(testImage)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAnalyzingPhoto)
    }
}
#endif

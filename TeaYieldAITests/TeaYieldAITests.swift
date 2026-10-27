import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("TeaYield AI Test Suite Smoke Verification")
struct TeaYieldAISmokeTests {

    @Test("Verifies AppConfiguration defaults align with Sri Lanka tea standards")
    func appConfigurationStandards() {
        #expect(AppConfiguration.fineLeafTargetRatio == 0.85)
        #expect(AppConfiguration.benchmarkYieldPerAcreKg == 195.0)
        #expect(AppConfiguration.timeoutInterval == 15.0)
    }

    @Test("Verifies AppContainer dependency injection wiring")
    @MainActor
    func appContainerWiring() {
        let container = AppContainer.shared
        #expect(container.apiService != nil)
        #expect(container.authService != nil)
        #expect(container.fieldRepository != nil)
        #expect(container.harvestRepository != nil)
        #expect(container.syncManager != nil)
        #expect(container.cameraService != nil)
        #expect(container.visionLeafClassifier != nil)
        #expect(container.locationService != nil)
    }
}

#else
import XCTest

final class TeaYieldAITests: XCTestCase {

    func testAppConfigurationStandards() {
        XCTAssertEqual(AppConfiguration.fineLeafTargetRatio, 0.85)
        XCTAssertEqual(AppConfiguration.benchmarkYieldPerAcreKg, 195.0)
        XCTAssertEqual(AppConfiguration.timeoutInterval, 15.0)
    }

    @MainActor
    func testAppContainerWiring() {
        let container = AppContainer.shared
        XCTAssertNotNil(container.apiService)
        XCTAssertNotNil(container.authService)
        XCTAssertNotNil(container.fieldRepository)
        XCTAssertNotNil(container.harvestRepository)
        XCTAssertNotNil(container.syncManager)
        XCTAssertNotNil(container.cameraService)
        XCTAssertNotNil(container.visionLeafClassifier)
        XCTAssertNotNil(container.locationService)
    }
}
#endif

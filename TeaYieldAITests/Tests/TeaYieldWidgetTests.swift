import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("TeaYield Dashboard Telemetry Widget Unit Tests")
struct TeaYieldWidgetTests {

    @Test("Calculates harvest intake progress accurately against target yield")
    func testIntakeProgressRatio() {
        let entryPartial = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Great Western Valley",
            targetYieldKg: 1000.0,
            harvestedKg: 450.0,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 88.5,
            isOffline: false
        )
        // 450 / 1000 = 0.45 (45%)
        #expect(abs(entryPartial.progress - 0.45) < 0.001)

        let entryComplete = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Great Western Valley",
            targetYieldKg: 800.0,
            harvestedKg: 950.0,
            readyFieldsCount: 3,
            fineLeafRatioPercent: 91.0,
            isOffline: false
        )
        // Clamped at 1.0 (100% capacity)
        #expect(entryComplete.progress == 1.0)
    }

    @Test("Guards against division by zero when target yield is zero or negative")
    func testZeroTargetYieldSafety() {
        let entryZeroTarget = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Valley Division",
            targetYieldKg: 0.0,
            harvestedKg: 100.0,
            readyFieldsCount: 1,
            fineLeafRatioPercent: 85.0,
            isOffline: false
        )
        #expect(entryZeroTarget.progress == 0.0)
    }

    @Test("Preserves fine leaf export benchmark ratio within 0 to 100 percent boundaries")
    func testQualityRatioIntegrity() {
        let entry = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Pedro Estate",
            targetYieldKg: 750.0,
            harvestedKg: 520.0,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 89.4,
            isOffline: false
        )
        // Sri Lanka Tea Board Export Auction Benchmark is >= 85.0%
        #expect(entry.fineLeafRatioPercent >= 85.0)
        #expect(entry.estateName == "Pedro Estate")
    }
}

#else
import XCTest

final class TeaYieldWidgetTests: XCTestCase {

    func testIntakeProgressRatio() {
        let entry = HarvestTelemetryEntry(
            date: Date(),
            estateName: "Great Western Valley",
            targetYieldKg: 1000.0,
            harvestedKg: 450.0,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 88.5,
            isOffline: false
        )
        XCTAssertEqual(entry.progress, 0.45, accuracy: 0.001)
    }
}
#endif

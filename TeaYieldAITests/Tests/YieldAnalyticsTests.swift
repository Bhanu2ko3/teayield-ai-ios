import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Yield Analytics Domain & Chart Telemetry Tests")
struct YieldAnalyticsTests {

    // MARK: - DailyYieldComparison Tests

    @Test("Calculates positive yield variance when actual harvest exceeds prediction")
    func positiveYieldVariance() {
        let comparison = DailyYieldComparison(
            dayName: "Wednesday",
            date: Date(),
            predictedYieldKg: 750.0,
            actualHarvestedKg: 820.0
        )

        #expect(comparison.varianceKg == 70.0)
        #expect(comparison.formattedVariance == "+70.0 kg")
    }

    @Test("Calculates negative yield variance when harvest falls short of prediction")
    func negativeYieldVariance() {
        let comparison = DailyYieldComparison(
            dayName: "Thursday",
            date: Date(),
            predictedYieldKg: 800.0,
            actualHarvestedKg: 740.0
        )

        #expect(comparison.varianceKg == -60.0)
        #expect(comparison.formattedVariance == "-60.0 kg")
    }

    @Test("Evaluates achievement ratio correctly against target")
    func achievementRatioCalculation() {
        let comparison = DailyYieldComparison(
            dayName: "Friday",
            date: Date(),
            predictedYieldKg: 500.0,
            actualHarvestedKg: 600.0
        )

        #expect(comparison.achievementRatio == 1.2)
    }

    @Test("Handles zero predicted yield safely without divide-by-zero crash")
    func zeroPredictedYieldSafety() {
        let comparison = DailyYieldComparison(
            dayName: "Sunday",
            date: Date(),
            predictedYieldKg: 0.0,
            actualHarvestedKg: 0.0
        )

        #expect(comparison.achievementRatio == 0.0)
        #expect(comparison.varianceKg == 0.0)
    }

    @Test("Verifies DailyYieldComparison Codable roundtrip serialization")
    func dailyYieldCodableRoundtrip() throws {
        let original = DailyYieldComparison(
            dayName: "Monday",
            date: Date(timeIntervalSince1970: 1672531199),
            predictedYieldKg: 650.0,
            actualHarvestedKg: 690.0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DailyYieldComparison.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.dayName == original.dayName)
        #expect(decoded.predictedYieldKg == original.predictedYieldKg)
        #expect(decoded.actualHarvestedKg == original.actualHarvestedKg)
    }

    // MARK: - NDVITrendPoint Tests

    @Test("Identifies canopy vigor at or above threshold as harvest-ready")
    func ndviReadinessThresholdReached() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 6",
            weekIndex: 6,
            ndviScore: 0.78,
            targetThreshold: 0.75
        )

        #expect(point.isHarvestReady == true)
    }

    @Test("Identifies canopy vigor below threshold as not harvest-ready")
    func ndviReadinessThresholdNotReached() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 2",
            weekIndex: 2,
            ndviScore: 0.65,
            targetThreshold: 0.75
        )

        #expect(point.isHarvestReady == false)
    }

    @Test("Verifies boundary condition when NDVI equals threshold exactly")
    func ndviExactBoundaryReadiness() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 5",
            weekIndex: 5,
            ndviScore: 0.75,
            targetThreshold: 0.75
        )

        #expect(point.isHarvestReady == true)
    }

    @Test("Verifies NDVITrendPoint Codable roundtrip serialization")
    func ndviTrendCodableRoundtrip() throws {
        let original = NDVITrendPoint(
            weekLabel: "Wk 4",
            weekIndex: 4,
            ndviScore: 0.72,
            targetThreshold: 0.75
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(NDVITrendPoint.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.weekLabel == original.weekLabel)
        #expect(decoded.weekIndex == original.weekIndex)
        #expect(decoded.ndviScore == original.ndviScore)
        #expect(decoded.targetThreshold == original.targetThreshold)
    }
}
#endif

// MARK: - XCTestCase Fallback for Xcode 14.3.1 / iOS 16.4 SDK

#if !canImport(Testing)
import XCTest

final class YieldAnalyticsLegacyTests: XCTestCase {

    func testPositiveYieldVariance() {
        let comparison = DailyYieldComparison(
            dayName: "Wednesday",
            date: Date(),
            predictedYieldKg: 750.0,
            actualHarvestedKg: 820.0
        )

        XCTAssertEqual(comparison.varianceKg, 70.0)
        XCTAssertEqual(comparison.formattedVariance, "+70.0 kg")
    }

    func testNegativeYieldVariance() {
        let comparison = DailyYieldComparison(
            dayName: "Thursday",
            date: Date(),
            predictedYieldKg: 800.0,
            actualHarvestedKg: 740.0
        )

        XCTAssertEqual(comparison.varianceKg, -60.0)
        XCTAssertEqual(comparison.formattedVariance, "-60.0 kg")
    }

    func testAchievementRatioCalculation() {
        let comparison = DailyYieldComparison(
            dayName: "Friday",
            date: Date(),
            predictedYieldKg: 500.0,
            actualHarvestedKg: 600.0
        )

        XCTAssertEqual(comparison.achievementRatio, 1.2)
    }

    func testZeroPredictedYieldSafety() {
        let comparison = DailyYieldComparison(
            dayName: "Sunday",
            date: Date(),
            predictedYieldKg: 0.0,
            actualHarvestedKg: 0.0
        )

        XCTAssertEqual(comparison.achievementRatio, 0.0)
        XCTAssertEqual(comparison.varianceKg, 0.0)
    }

    func testDailyYieldCodableRoundtrip() throws {
        let original = DailyYieldComparison(
            dayName: "Monday",
            date: Date(timeIntervalSince1970: 1672531199),
            predictedYieldKg: 650.0,
            actualHarvestedKg: 690.0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DailyYieldComparison.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.dayName, original.dayName)
        XCTAssertEqual(decoded.predictedYieldKg, original.predictedYieldKg)
        XCTAssertEqual(decoded.actualHarvestedKg, original.actualHarvestedKg)
    }

    func testNDVIReadinessThresholdReached() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 6",
            weekIndex: 6,
            ndviScore: 0.78,
            targetThreshold: 0.75
        )

        XCTAssertTrue(point.isHarvestReady)
    }

    func testNDVIReadinessThresholdNotReached() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 2",
            weekIndex: 2,
            ndviScore: 0.65,
            targetThreshold: 0.75
        )

        XCTAssertFalse(point.isHarvestReady)
    }

    func testNDVIExactBoundaryReadiness() {
        let point = NDVITrendPoint(
            weekLabel: "Wk 5",
            weekIndex: 5,
            ndviScore: 0.75,
            targetThreshold: 0.75
        )

        XCTAssertTrue(point.isHarvestReady)
    }

    func testNDVITrendCodableRoundtrip() throws {
        let original = NDVITrendPoint(
            weekLabel: "Wk 4",
            weekIndex: 4,
            ndviScore: 0.72,
            targetThreshold: 0.75
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(NDVITrendPoint.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.weekLabel, original.weekLabel)
        XCTAssertEqual(decoded.weekIndex, original.weekIndex)
        XCTAssertEqual(decoded.ndviScore, original.ndviScore)
        XCTAssertEqual(decoded.targetThreshold, original.targetThreshold)
    }
}
#endif

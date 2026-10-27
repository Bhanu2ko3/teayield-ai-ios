import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Harvest History ViewModel Unit Tests")
@MainActor
struct HarvestHistoryViewModelTests {

    private func createSampleRecords() -> [HarvestRecord] {
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        return [
            HarvestRecord(
                id: UUID(),
                fieldId: UUID(),
                pluckerId: "PLK-010",
                pluckerName: "Sita Kumari",
                grossWeightKg: 25.5,
                tareWeightKg: 1.5,
                netWeightKg: 24.0,
                fineLeafRatio: 0.88,
                timestamp: baseDate.addingTimeInterval(3600), // Newer
                latitude: 6.965,
                longitude: 80.793,
                isSynced: true
            ),
            HarvestRecord(
                id: UUID(),
                fieldId: UUID(),
                pluckerId: "PLK-011",
                pluckerName: "Rani Perera",
                grossWeightKg: 22.0,
                tareWeightKg: 1.5,
                netWeightKg: 20.5,
                fineLeafRatio: 0.76,
                timestamp: baseDate, // Older
                latitude: 6.965,
                longitude: 80.793,
                isSynced: false
            )
        ]
    }

    @Test("Verifies loading records sorts chronologically descending")
    func loadRecordsSorting() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        #expect(viewModel.records.count == 2)
        #expect(viewModel.records.first?.pluckerId == "PLK-010") // Newer first
        #expect(viewModel.records.last?.pluckerId == "PLK-011")
    }

    @Test("Verifies filtering by synchronization state")
    func filterBySyncState() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        viewModel.filterSelection = .all
        #expect(viewModel.filteredRecords.count == 2)

        viewModel.filterSelection = .synced
        #expect(viewModel.filteredRecords.count == 1)
        #expect(viewModel.filteredRecords.first?.pluckerId == "PLK-010")

        viewModel.filterSelection = .offline
        #expect(viewModel.filteredRecords.count == 1)
        #expect(viewModel.filteredRecords.first?.pluckerId == "PLK-011")
    }

    @Test("Verifies search filtering by plucker name or identification code")
    func searchFiltering() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        viewModel.searchText = "Rani"
        #expect(viewModel.filteredRecords.count == 1)
        #expect(viewModel.filteredRecords.first?.pluckerName == "Rani Perera")

        viewModel.searchText = "PLK-010"
        #expect(viewModel.filteredRecords.count == 1)
        #expect(viewModel.filteredRecords.first?.pluckerId == "PLK-010")

        viewModel.searchText = "NonExistent"
        #expect(viewModel.filteredRecords.isEmpty)
    }

    @Test("Verifies aggregate weight and quality calculation")
    func aggregateMetrics() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        #expect(viewModel.totalHarvestedKg == 44.5) // 24.0 + 20.5
        #expect(abs(viewModel.averageFineLeafRatio - 0.82) < 0.001) // (0.88 + 0.76) / 2
    }
}

#else
import XCTest

@MainActor
final class HarvestHistoryViewModelTests: XCTestCase {

    private func createSampleRecords() -> [HarvestRecord] {
        let baseDate = Date(timeIntervalSince1970: 1700000000)
        return [
            HarvestRecord(
                id: UUID(),
                fieldId: UUID(),
                pluckerId: "PLK-010",
                pluckerName: "Sita Kumari",
                grossWeightKg: 25.5,
                tareWeightKg: 1.5,
                netWeightKg: 24.0,
                fineLeafRatio: 0.88,
                timestamp: baseDate.addingTimeInterval(3600),
                latitude: 6.965,
                longitude: 80.793,
                isSynced: true
            ),
            HarvestRecord(
                id: UUID(),
                fieldId: UUID(),
                pluckerId: "PLK-011",
                pluckerName: "Rani Perera",
                grossWeightKg: 22.0,
                tareWeightKg: 1.5,
                netWeightKg: 20.5,
                fineLeafRatio: 0.76,
                timestamp: baseDate,
                latitude: 6.965,
                longitude: 80.793,
                isSynced: false
            )
        ]
    }

    func testLoadRecordsSorting() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        XCTAssertEqual(viewModel.records.count, 2)
        XCTAssertEqual(viewModel.records.first?.pluckerId, "PLK-010")
        XCTAssertEqual(viewModel.records.last?.pluckerId, "PLK-011")
    }

    func testFilterBySyncState() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        viewModel.filterSelection = .all
        XCTAssertEqual(viewModel.filteredRecords.count, 2)

        viewModel.filterSelection = .synced
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.pluckerId, "PLK-010")

        viewModel.filterSelection = .offline
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.pluckerId, "PLK-011")
    }

    func testSearchFiltering() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        viewModel.searchText = "Rani"
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.pluckerName, "Rani Perera")

        viewModel.searchText = "PLK-010"
        XCTAssertEqual(viewModel.filteredRecords.count, 1)
        XCTAssertEqual(viewModel.filteredRecords.first?.pluckerId, "PLK-010")

        viewModel.searchText = "NonExistent"
        XCTAssertTrue(viewModel.filteredRecords.isEmpty)
    }

    func testAggregateMetrics() async {
        let samples = createSampleRecords()
        let repo = MockHarvestRepository(initialRecords: samples)
        let viewModel = HarvestHistoryViewModel(harvestRepository: repo)

        await viewModel.loadRecords()

        XCTAssertEqual(viewModel.totalHarvestedKg, 44.5)
        XCTAssertEqual(viewModel.averageFineLeafRatio, 0.82, accuracy: 0.001)
    }
}
#endif

import Foundation
import SwiftUI

/// Coordinates retrieval, time-range filtering, multi-criteria sorting, and search for harvest records.
/// Strictly conforms to Xcode 14.3.1 / iOS 16.4 baseline with ObservableObject and @MainActor.
@MainActor
final class HarvestHistoryViewModel: ObservableObject {

    // MARK: - Filter & Sort Enums

    enum SyncFilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case synced = "Synced"
        case offline = "Pending Sync"

        var id: String { rawValue }
    }

    enum TimeRangeOption: String, CaseIterable, Identifiable {
        case all = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"

        var id: String { rawValue }
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        case highestWeight = "Highest Weight"
        case lowestWeight = "Lowest Weight"
        case highestQuality = "Highest Quality"

        var id: String { rawValue }
    }

    // MARK: - Published State

    @Published var records: [HarvestRecord] = []
    @Published var isLoading: Bool = false
    @Published var filterSelection: SyncFilterOption = .all
    @Published var timeRangeSelection: TimeRangeOption = .all
    @Published var sortSelection: SortOption = .newestFirst
    @Published var searchText: String = ""

    // MARK: - Dependencies

    private let harvestRepository: HarvestRepositoryProtocol
    private let apiService: APIServiceProtocol?

    init(
        harvestRepository: HarvestRepositoryProtocol,
        apiService: APIServiceProtocol? = nil
    ) {
        self.harvestRepository = harvestRepository
        self.apiService = apiService
    }

    // MARK: - Filtered & Sorted Records

    var filteredRecords: [HarvestRecord] {
        var result = records
        let calendar = Calendar.current
        let now = Date()

        // 1. Filter by Time Range
        switch timeRangeSelection {
        case .all:
            break
        case .today:
            result = result.filter { calendar.isDateInToday($0.timestamp) }
        case .thisWeek:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { break }
            result = result.filter { $0.timestamp >= weekAgo }
        case .thisMonth:
            guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) else { break }
            result = result.filter { $0.timestamp >= monthAgo }
        }

        // 2. Filter by Sync Status
        switch filterSelection {
        case .all:
            break
        case .synced:
            result = result.filter { $0.isSynced }
        case .offline:
            result = result.filter { !$0.isSynced }
        }

        // 3. Filter by Search Text (Plucker Name or ID)
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            result = result.filter {
                $0.pluckerName.localizedCaseInsensitiveContains(trimmedSearch) ||
                $0.pluckerId.localizedCaseInsensitiveContains(trimmedSearch)
            }
        }

        // 4. Sort Records
        // Note: For Newest First, newly created unsynced local records are prioritized at the top
        // so field officers immediately see their latest batch entry.
        switch sortSelection {
        case .newestFirst:
            result.sort { first, second in
                if first.isSynced != second.isSynced {
                    return !first.isSynced && second.isSynced
                }
                return first.timestamp > second.timestamp
            }
        case .oldestFirst:
            result.sort(by: { $0.timestamp < $1.timestamp })
        case .highestWeight:
            result.sort(by: { $0.netWeightKg > $1.netWeightKg })
        case .lowestWeight:
            result.sort(by: { $0.netWeightKg < $1.netWeightKg })
        case .highestQuality:
            result.sort(by: { $0.fineLeafRatio > $1.fineLeafRatio })
        }

        return result
    }

    // MARK: - Aggregate Metrics

    var totalHarvestedKg: Double {
        filteredRecords.reduce(0.0) { $0 + $1.netWeightKg }
    }

    var averageFineLeafRatio: Double {
        guard !filteredRecords.isEmpty else { return 0.0 }
        let total = filteredRecords.reduce(0.0) { $0 + $1.fineLeafRatio }
        return total / Double(filteredRecords.count)
    }

    var filteredRecordsCount: Int {
        filteredRecords.count
    }

    // MARK: - Data Retrieval

    func loadRecords() async {
        isLoading = true
        defer { isLoading = false }

        // Optional cloud refresh to pull server-side records
        if let api = apiService,
           let serverLogs = try? await api.fetchHarvestLogs(fieldId: nil, limit: 100, offset: 0),
           !serverLogs.isEmpty {
            for log in serverLogs {
                try? await harvestRepository.saveRecord(log.toDomain())
            }
        }

        do {
            let fetched = try await harvestRepository.fetchAllRecords()
            self.records = fetched
        } catch {
            self.records = []
        }
    }
}

import Foundation
import SwiftUI

/// Coordinates retrieval and filtering of locally persisted Core Data harvest weighing records.
@MainActor
final class HarvestHistoryViewModel: ObservableObject {

    @Published var records: [HarvestRecord] = []
    @Published var isLoading: Bool = false
    @Published var filterSelection: FilterOption = .all
    @Published var searchText: String = ""

    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case synced = "Synced"
        case offline = "Pending Sync"

        var id: String { rawValue }
    }

    private let harvestRepository: HarvestRepositoryProtocol

    init(harvestRepository: HarvestRepositoryProtocol) {
        self.harvestRepository = harvestRepository
    }

    var filteredRecords: [HarvestRecord] {
        var result = records

        switch filterSelection {
        case .all:
            break
        case .synced:
            result = result.filter { $0.isSynced }
        case .offline:
            result = result.filter { !$0.isSynced }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.pluckerName.localizedCaseInsensitiveContains(searchText) ||
                $0.pluckerId.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var totalHarvestedKg: Double {
        records.reduce(0.0) { $0 + $1.netWeightKg }
    }

    var averageFineLeafRatio: Double {
        guard !records.isEmpty else { return 0.0 }
        let total = records.reduce(0.0) { $0 + $1.fineLeafRatio }
        return total / Double(records.count)
    }

    func loadRecords() async {
        isLoading = true
        do {
            let fetched = try await harvestRepository.fetchAllRecords()
            self.records = fetched.sorted(by: { $0.timestamp > $1.timestamp })
            self.isLoading = false
        } catch {
            self.records = []
            self.isLoading = false
        }
    }
}

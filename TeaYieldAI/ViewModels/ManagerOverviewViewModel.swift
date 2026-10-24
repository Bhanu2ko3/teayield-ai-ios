import Foundation
import SwiftUI

/// Coordinates estate-wide macro telemetry, factory intake metrics, and NDVI health summaries for estate managers.
@MainActor
final class ManagerOverviewViewModel: ObservableObject {

    @Published var fields: [TeaField] = []
    @Published var totalHarvestTodayKg: Double = 0.0
    @Published var isLoading: Bool = false

    /// Standard withering trough capacity limit to prevent factory overloading.
    let factoryIntakeCapKg: Double = 3000.0

    private let fieldRepository: FieldRepositoryProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let authService: AuthServiceProtocol

    init(
        fieldRepository: FieldRepositoryProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        authService: AuthServiceProtocol
    ) {
        self.fieldRepository = fieldRepository
        self.harvestRepository = harvestRepository
        self.authService = authService
    }

    var managerName: String {
        authService.currentUser?.fullName ?? "Estate Manager"
    }

    var managerEmail: String {
        authService.currentUser?.email ?? "manager@estate.lk"
    }

    var totalAcreage: Double {
        fields.reduce(0.0) { $0 + $1.acreage }
    }

    var readyFieldsCount: Int {
        fields.filter { $0.status == .ready }.count
    }

    var growingFieldsCount: Int {
        fields.filter { $0.status == .growing }.count
    }

    var restingFieldsCount: Int {
        fields.filter { $0.status == .resting }.count
    }

    var factoryUtilizationRatio: Double {
        guard factoryIntakeCapKg > 0 else { return 0.0 }
        return min(1.0, totalHarvestTodayKg / factoryIntakeCapKg)
    }

    func loadEstateTelemetry() async {
        isLoading = true
        do {
            let fetchedFields = try await fieldRepository.fetchAllFields()
            let fetchedRecords = try await harvestRepository.fetchAllRecords()

            self.fields = fetchedFields
            self.totalHarvestTodayKg = fetchedRecords.reduce(0.0) { $0 + $1.netWeightKg }
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }

    func logout() {
        authService.logout()
    }
}

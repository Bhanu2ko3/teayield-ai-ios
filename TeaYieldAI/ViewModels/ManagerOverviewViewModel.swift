import Foundation
import SwiftUI

/// Coordinates estate-wide macro telemetry, factory intake metrics, and NDVI health summaries for estate managers.
@MainActor
final class ManagerOverviewViewModel: ObservableObject {

    @Published var fields: [TeaField] = []
    @Published var totalHarvestTodayKg: Double = 0.0
    @Published var averageFineLeafPercentage: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var showingLogoutConfirmation: Bool = false
    @Published var estateName: String = ""
    @Published var factoryIntakeCapKg: Double = 3000.0

    private let fieldRepository: FieldRepositoryProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol

    init(
        fieldRepository: FieldRepositoryProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        authService: AuthServiceProtocol,
        apiService: APIServiceProtocol
    ) {
        self.fieldRepository = fieldRepository
        self.harvestRepository = harvestRepository
        self.authService = authService
        self.apiService = apiService
    }

    var managerName: String {
        authService.currentUser?.fullName ?? ""
    }

    var managerEmployeeId: String {
        authService.currentUser?.employeeId ?? ""
    }

    var managerEmail: String {
        authService.currentUser?.email ?? ""
    }

    var estateDisplayName: String {
        if !estateName.isEmpty {
            return estateName
        }
        if let user = authService.currentUser {
            return "Estate #\(user.estateId.uuidString.prefix(6).uppercased())"
        }
        return "Estate Unassigned"
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

    var remainingCapacityKg: Double {
        max(0.0, factoryIntakeCapKg - totalHarvestTodayKg)
    }

    func loadEstateTelemetry() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let user = authService.currentUser else {
            errorMessage = "No authenticated session. Please sign in."
            showErrorAlert = true
            return
        }

        do {
            // Fetch estate enterprise profile dynamically
            if let estate = try? await apiService.fetchEstate(id: user.estateId) {
                self.estateName = estate.name
                self.factoryIntakeCapKg = estate.dailyFactoryCapacityKg
            }

            var fetchedFields = try await fieldRepository.fetchAllFields()
            if fetchedFields.isEmpty {
                if let dtos = try? await apiService.fetchFields(estateId: user.estateId) {
                    let domainFields = dtos.map { $0.toDomain() }
                    try? await fieldRepository.saveFields(domainFields)
                    fetchedFields = domainFields
                }
            }

            let fetchedRecords = try await harvestRepository.fetchAllRecords()

            self.fields = fetchedFields
            self.totalHarvestTodayKg = fetchedRecords.reduce(0.0) { $0 + $1.netWeightKg }

            if !fetchedRecords.isEmpty {
                let totalFine = fetchedRecords.reduce(0.0) { $0 + $1.fineLeafRatio }
                self.averageFineLeafPercentage = (totalFine / Double(fetchedRecords.count)) * 100.0
            } else {
                self.averageFineLeafPercentage = 0.0
            }
        } catch {
            self.errorMessage = "Failed to synchronize estate telemetry: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }

    func logout() {
        authService.logout()
    }
}

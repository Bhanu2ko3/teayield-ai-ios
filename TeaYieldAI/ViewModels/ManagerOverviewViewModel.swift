import Foundation
import SwiftUI

/// Coordinates estate-wide macro telemetry, factory intake metrics, and NDVI health summaries for estate managers.
@MainActor
final class ManagerOverviewViewModel: ObservableObject {

    @Published var fields: [TeaField] = []
    @Published var totalHarvestTodayKg: Double = 0.0
    @Published var averageFineLeafPercentage: Double = 85.0
    @Published var isLoading: Bool = false
    @Published var showingLogoutConfirmation: Bool = false

    /// Standard withering trough capacity limit to prevent factory overloading.
    let factoryIntakeCapKg: Double = 3000.0

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
        authService.currentUser?.fullName ?? "Bhanuka Bandara"
    }

    var managerEmployeeId: String {
        authService.currentUser?.employeeId ?? "MGR-082"
    }

    var managerEmail: String {
        authService.currentUser?.email ?? "manager@estate.lk"
    }

    var estateDisplayName: String {
        "Pedro Estate • Nuwara Eliya"
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
        defer { isLoading = false }

        guard let user = authService.currentUser else { return }

        do {
            var fetchedFields = try await fieldRepository.fetchAllFields()
            if fetchedFields.isEmpty {
                if let dtos = try? await apiService.fetchFields(estateId: user.estateId) {
                    let domainFields = dtos.map { $0.toDomain() }
                    try? await fieldRepository.saveFields(domainFields)
                    fetchedFields = domainFields
                } else {
                    // Seed initial Pedro Estate fields into Core Data if local database is empty
                    let defaultFields: [TeaField] = [
                        TeaField(
                            id: UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")!,
                            estateId: user.estateId,
                            name: "Upper Division Block A",
                            blockCode: "UD-BLK-A",
                            acreage: 12.50,
                            currentNDVI: 0.820,
                            status: .ready,
                            centroidLatitude: 6.9642,
                            centroidLongitude: 80.7932,
                            polygonCoordinates: [],
                            lastHarvestedDate: Date().addingTimeInterval(-86400 * 7)
                        ),
                        TeaField(
                            id: UUID(uuidString: "8d0f778a-8536-41ef-055c-f18fd2a01bf8")!,
                            estateId: user.estateId,
                            name: "Lower Division Block B",
                            blockCode: "LD-BLK-B",
                            acreage: 18.20,
                            currentNDVI: 0.760,
                            status: .ready,
                            centroidLatitude: 6.9615,
                            centroidLongitude: 80.7950,
                            polygonCoordinates: [],
                            lastHarvestedDate: Date().addingTimeInterval(-86400 * 9)
                        ),
                        TeaField(
                            id: UUID(uuidString: "9e1a889b-9647-42fa-166d-a29fe3b12ca9")!,
                            estateId: user.estateId,
                            name: "Ragala Division Block C",
                            blockCode: "RD-BLK-C",
                            acreage: 14.80,
                            currentNDVI: 0.640,
                            status: .growing,
                            centroidLatitude: 6.9680,
                            centroidLongitude: 80.7910,
                            polygonCoordinates: [],
                            lastHarvestedDate: Date().addingTimeInterval(-86400 * 4)
                        ),
                        TeaField(
                            id: UUID(uuidString: "af2b99ac-0758-430b-277e-b30af4c23db0")!,
                            estateId: user.estateId,
                            name: "Oliphant Division Block D",
                            blockCode: "OD-BLK-D",
                            acreage: 10.00,
                            currentNDVI: 0.480,
                            status: .resting,
                            centroidLatitude: 6.9590,
                            centroidLongitude: 80.7980,
                            polygonCoordinates: [],
                            lastHarvestedDate: Date().addingTimeInterval(-86400 * 1)
                        )
                    ]
                    try? await fieldRepository.saveFields(defaultFields)
                    fetchedFields = defaultFields
                }
            }

            let fetchedRecords = try await harvestRepository.fetchAllRecords()

            self.fields = fetchedFields
            self.totalHarvestTodayKg = fetchedRecords.reduce(0.0) { $0 + $1.netWeightKg }

            if !fetchedRecords.isEmpty {
                let totalFine = fetchedRecords.reduce(0.0) { $0 + $1.fineLeafRatio }
                self.averageFineLeafPercentage = (totalFine / Double(fetchedRecords.count)) * 100.0
            } else {
                self.averageFineLeafPercentage = 85.0
            }
        } catch {
            // Error handling maintains previous values
        }
    }

    func logout() {
        authService.logout()
    }
}

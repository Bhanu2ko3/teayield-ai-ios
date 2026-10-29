import Foundation
import SwiftUI

/// Coordinates weighing scale data entry, fine leaf ratio quality grading, and Core Data persistence.
@MainActor
final class HarvestWeighingViewModel: ObservableObject {

    @Published var selectedFieldId: UUID?
    @Published var availableFields: [TeaField] = []
    @Published var availablePluckers: [Plucker] = []
    @Published var selectedPlucker: Plucker? = nil
    @Published var isLoadingPluckers: Bool = false
    @Published var pluckerId: String = ""
    @Published var pluckerName: String = ""
    @Published var grossWeightInput: String = ""
    @Published var bagTareWeightInput: String = "1.5"
    @Published var fineLeafRatio: Double = AppConfiguration.fineLeafTargetRatio
    @Published var notes: String = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var validationMessage: String?
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var savedSummary: String?

    var grossWeight: Double {
        Double(grossWeightInput.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }

    var bagTareWeight: Double {
        Double(bagTareWeightInput.replacingOccurrences(of: ",", with: ".")) ?? 1.5
    }

    var netWeight: Double {
        max(0.0, grossWeight - bagTareWeight)
    }

    var isQualityExportGrade: Bool {
        fineLeafRatio >= AppConfiguration.fineLeafTargetRatio
    }

    var isFormValid: Bool {
        selectedFieldId != nil &&
        !pluckerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        grossWeight > bagTareWeight &&
        grossWeight > 0.0 &&
        bagTareWeight >= 0.0 &&
        fineLeafRatio >= 0.0 &&
        fineLeafRatio <= 1.0
    }

    private let harvestRepository: HarvestRepositoryProtocol
    private let fieldRepository: FieldRepositoryProtocol
    private let syncManager: SyncManagerProtocol
    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol

    init(
        harvestRepository: HarvestRepositoryProtocol,
        fieldRepository: FieldRepositoryProtocol,
        syncManager: SyncManagerProtocol,
        authService: AuthServiceProtocol,
        apiService: APIServiceProtocol,
        initialFieldId: UUID? = nil,
        initialFineLeafRatio: Double? = nil
    ) {
        self.harvestRepository = harvestRepository
        self.fieldRepository = fieldRepository
        self.syncManager = syncManager
        self.authService = authService
        self.apiService = apiService
        self.selectedFieldId = initialFieldId
        if let ratio = initialFineLeafRatio {
            self.fineLeafRatio = ratio
        }

        Task {
            await loadAvailableFields()
            await loadAvailablePluckers()
        }
    }

    // MARK: - Plucker Workforce Loading

    /// Loads registered pluckers for the active estate from the backend API or offline cache.
    func loadAvailablePluckers() async {
        guard let user = authService.currentUser else { return }
        isLoadingPluckers = true
        defer { isLoadingPluckers = false }

        do {
            let dtos = try await apiService.fetchPluckers(estateId: user.estateId)
            let domainPluckers = dtos.map { $0.toDomain() }
            self.availablePluckers = domainPluckers.isEmpty ? MockData.samplePluckers : domainPluckers
        } catch {
            // Graceful fallback to cached mock workforce during offline operations
            self.availablePluckers = MockData.samplePluckers
        }
    }

    /// Selects a registered plucker and auto-populates the identification fields.
    func selectPlucker(_ plucker: Plucker) {
        self.selectedPlucker = plucker
        self.pluckerId = plucker.pluckerCode
        self.pluckerName = plucker.fullName
    }

    // MARK: - Field Loading

    /// Loads available estate fields from local persistence or syncs from remote API.
    func loadAvailableFields() async {
        guard let user = authService.currentUser else { return }

        do {
            var fields = try await fieldRepository.fetchAllFields()
            if fields.isEmpty {
                // If local cache is empty, fetch fresh fields from remote API
                if let dtos = try? await apiService.fetchFields(estateId: user.estateId) {
                    let domainFields = dtos.map { $0.toDomain() }
                    try? await fieldRepository.saveFields(domainFields)
                    fields = domainFields
                }
            }

            self.availableFields = fields
            if selectedFieldId == nil, let first = fields.first {
                self.selectedFieldId = first.id
                self.latitude = first.centroidLatitude
                self.longitude = first.centroidLongitude
            } else if let selected = fields.first(where: { $0.id == selectedFieldId }) {
                self.latitude = selected.centroidLatitude
                self.longitude = selected.centroidLongitude
            }
        } catch {
            errorMessage = "Failed to load estate fields: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    /// Updates coordinates to match selected field centroid.
    func updateCoordinatesForSelectedField() {
        guard let field = availableFields.first(where: { $0.id == selectedFieldId }) else { return }
        self.latitude = field.centroidLatitude
        self.longitude = field.centroidLongitude
    }

    /// Sets preset bag tare weights commonly used in Sri Lankan tea estates.
    func selectTarePreset(_ weight: Double) {
        self.bagTareWeightInput = String(format: "%.1f", weight)
    }

    // MARK: - Save Action

    /// Validates inputs and stores the harvest record in Core Data with offline synchronization flags.
    func saveWeighingRecord() async -> Bool {
        guard validateInputs() else { return false }
        guard let fieldId = selectedFieldId else { return false }
        guard let user = authService.currentUser else {
            errorMessage = "User session expired. Please sign in again."
            showErrorAlert = true
            return false
        }

        isSaving = true
        validationMessage = nil
        errorMessage = nil

        let trimmedPluckerId = pluckerId.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let resolvedPluckerName = pluckerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Plucker \(trimmedPluckerId)"
            : pluckerName.trimmingCharacters(in: .whitespacesAndNewlines)

        let record = HarvestRecord(
            id: UUID(),
            fieldId: fieldId,
            pluckerId: trimmedPluckerId,
            pluckerName: resolvedPluckerName,
            grossWeightKg: grossWeight,
            tareWeightKg: bagTareWeight,
            netWeightKg: netWeight,
            fineLeafRatio: fineLeafRatio,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude,
            isSynced: false
        )

        do {
            try await harvestRepository.saveRecord(record)
            isSaving = false
            saveSuccess = true
            savedSummary = String(format: "Saved %.1f kg (Net) for %@", netWeight, record.pluckerName)

            // Trigger non-blocking opportunistic background sync if device has connectivity
            Task {
                _ = try? await syncManager.syncPendingRecords(supervisorId: user.employeeId)
            }

            // Reset dynamic fields for next plucker in queue, retaining field and tare
            pluckerId = ""
            pluckerName = ""
            grossWeightInput = ""
            fineLeafRatio = AppConfiguration.fineLeafTargetRatio
            notes = ""

            return true
        } catch {
            isSaving = false
            errorMessage = "Failed to save record to local database: \(error.localizedDescription)"
            showErrorAlert = true
            return false
        }
    }

    // MARK: - Validation

    private func validateInputs() -> Bool {
        if selectedFieldId == nil {
            validationMessage = "Please select a tea field."
            return false
        }

        if pluckerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Plucker ID cannot be empty."
            return false
        }

        if grossWeight <= 0.0 {
            validationMessage = "Gross weight must be greater than 0 kg."
            return false
        }

        if grossWeight <= bagTareWeight {
            validationMessage = "Gross weight must be greater than bag tare weight (\(bagTareWeight) kg)."
            return false
        }

        if fineLeafRatio < 0.0 || fineLeafRatio > 1.0 {
            validationMessage = "Fine leaf ratio must be between 0% and 100%."
            return false
        }

        validationMessage = nil
        return true
    }
}

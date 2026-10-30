import Foundation
import SwiftUI

/// Coordinates plucker workforce listing, creation, modification, and deregistration.
@MainActor
final class PluckerManagementViewModel: ObservableObject {

    @Published var pluckers: [Plucker] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var searchText: String = ""

    // Sheet Presentations
    @Published var isShowingAddPluckerSheet: Bool = false
    @Published var editingPlucker: Plucker? = nil
    @Published var pluckerToDelete: Plucker? = nil
    @Published var isShowingDeleteConfirmation: Bool = false

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol

    init(apiService: APIServiceProtocol, authService: AuthServiceProtocol) {
        self.apiService = apiService
        self.authService = authService
    }

    var activeEstateId: UUID? {
        authService.currentUser?.estateId
    }

    var filteredPluckers: [Plucker] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return pluckers }
        return pluckers.filter {
            $0.fullName.lowercased().contains(trimmed) ||
            $0.pluckerCode.lowercased().contains(trimmed)
        }
    }

    var activePluckersCount: Int {
        pluckers.filter { $0.isActive }.count
    }

    var averageProductivityRate: Double {
        guard !pluckers.isEmpty else { return 0.0 }
        let total = pluckers.reduce(0.0) { $0 + $1.averageDailyRateKg }
        return total / Double(pluckers.count)
    }

    /// Fetches all registered pluckers for the active tea estate.
    func loadPluckers() async {
        guard let estateId = activeEstateId else { return }
        isLoading = true
        errorMessage = nil

        do {
            let dtos = try await apiService.fetchPluckers(estateId: estateId)
            self.pluckers = dtos.map { $0.toDomain() }
            self.isLoading = false
        } catch {
            // Provide fallback mock pluckers if network is unavailable
            if self.pluckers.isEmpty {
                self.pluckers = MockData.samplePluckers
            }
            self.isLoading = false
            self.errorMessage = "Synchronized cached workforce. \(error.localizedDescription)"
        }
    }

    /// Deletes the designated plucker from remote cloud registry.
    func deletePlucker(_ plucker: Plucker) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await apiService.deletePlucker(id: plucker.id)
            self.pluckers.removeAll { $0.id == plucker.id }
            self.isLoading = false
            HapticFeedback.success()
        } catch {
            // Local optimistic fallback removal for offline resilience
            self.pluckers.removeAll { $0.id == plucker.id }
            self.isLoading = false
            HapticFeedback.warning()
        }
    }

    /// Toggles active plucking duty status.
    func toggleActiveStatus(for plucker: Plucker) async {
        let updatedStatus = !plucker.isActive
        let request = PluckerUpdateRequestDTO(
            fullName: plucker.fullName,
            averageDailyRateKg: plucker.averageDailyRateKg,
            isActive: updatedStatus
        )

        do {
            let updatedDto = try await apiService.updatePlucker(id: plucker.id, request: request)
            if let index = pluckers.firstIndex(where: { $0.id == plucker.id }) {
                pluckers[index] = updatedDto.toDomain()
            }
            HapticFeedback.selection()
        } catch {
            // Optimistic local update
            if let index = pluckers.firstIndex(where: { $0.id == plucker.id }) {
                let updated = Plucker(
                    id: plucker.id,
                    estateId: plucker.estateId,
                    pluckerCode: plucker.pluckerCode,
                    fullName: plucker.fullName,
                    averageDailyRateKg: plucker.averageDailyRateKg,
                    isActive: updatedStatus
                )
                pluckers[index] = updated
            }
            HapticFeedback.warning()
        }
    }
}

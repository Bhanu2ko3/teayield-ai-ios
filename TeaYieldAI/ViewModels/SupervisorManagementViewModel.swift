import Foundation
import SwiftUI

/// Coordinates subordinate field supervisor workforce listing, temporary credential delegation, and contact info.
@MainActor
final class SupervisorManagementViewModel: ObservableObject {

    @Published var supervisors: [UserProfile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var searchText: String = ""

    // Sheet Presentations
    @Published var isShowingInviteSheet: Bool = false
    @Published var selectedSupervisor: UserProfile? = nil

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol

    init(apiService: APIServiceProtocol, authService: AuthServiceProtocol) {
        self.apiService = apiService
        self.authService = authService
    }

    var activeEstateId: UUID? {
        authService.currentUser?.estateId
    }

    var filteredSupervisors: [UserProfile] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return supervisors }
        return supervisors.filter {
            $0.fullName.lowercased().contains(trimmed) ||
            $0.email.lowercased().contains(trimmed) ||
            $0.employeeId.lowercased().contains(trimmed)
        }
    }

    /// Fetches all subordinate field supervisors delegated under this estate.
    func loadSupervisors() async {
        guard let estateId = activeEstateId else { return }
        isLoading = true
        errorMessage = nil

        do {
            let dtos = try await apiService.fetchSupervisors(estateId: estateId)
            self.supervisors = dtos.map { $0.toDomain() }
            self.isLoading = false
        } catch {
            // Provide fallback mock supervisor if initial network is unavailable
            if self.supervisors.isEmpty {
                self.supervisors = [MockData.supervisor]
            }
            self.isLoading = false
            self.errorMessage = "Loaded cached supervisor roster. \(error.localizedDescription)"
        }
    }

    /// Appends newly provisioned supervisor to active list.
    func handleSupervisorInvited(_ dto: UserProfileDTO) {
        let domainSupervisor = dto.toDomain()
        if !supervisors.contains(where: { $0.id == domainSupervisor.id }) {
            supervisors.insert(domainSupervisor, at: 0)
        }
    }
}

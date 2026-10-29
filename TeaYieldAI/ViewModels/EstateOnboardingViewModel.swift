import Foundation
import SwiftUI

/// Coordinates estate parameter ingestion, mathematical prior validation, and initial tenant setup.
@MainActor
final class EstateOnboardingViewModel: ObservableObject {

    @Published var estateName: String = ""
    @Published var selectedDistrict: String = "Nuwara Eliya"
    @Published var elevationInput: String = "1868"
    @Published var totalAcresInput: String = "450.0"
    @Published var dailyFactoryCapacityInput: String = "25000.0"

    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var onboardingSuccess: Bool = false

    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol

    init(authService: AuthServiceProtocol, apiService: APIServiceProtocol) {
        self.authService = authService
        self.apiService = apiService
    }

    /// Validates estate parameters against physical agronomic boundaries.
    var isFormValid: Bool {
        let nameTrimmed = estateName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameTrimmed.count >= 2 && nameTrimmed.count <= 150 else { return false }

        guard let elevation = Int(elevationInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              elevation >= 50 && elevation <= 2600 else { return false }

        guard let acres = Double(totalAcresInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              acres > 0.0 && acres <= 50000.0 else { return false }

        guard let capacity = Double(dailyFactoryCapacityInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              capacity > 0.0 && capacity <= 200000.0 else { return false }

        return true
    }

    /// Automatically synchronizes the elevation estimate when the district selection updates.
    func applyDistrictDefaults(_ district: SriLankanTeaDistrict) {
        let defaultElevation = max(50, district.defaultElevationMeters)
        self.elevationInput = "\(defaultElevation)"
    }

    /// Dispatches the estate onboarding payload to the backend and updates the user tenant session.
    func onboardEstate() async {
        guard isFormValid else {
            errorMessage = "Please enter a valid estate designation (min 2 chars), elevation between 50m and 2,600m, acreage between 1 and 50,000, and factory capacity up to 200,000 kg/day."
            showErrorAlert = true
            return
        }

        guard let elevation = Int(elevationInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              let acres = Double(totalAcresInput.trimmingCharacters(in: .whitespacesAndNewlines)),
              let capacity = Double(dailyFactoryCapacityInput.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            errorMessage = "Please verify numeric entries for elevation, acreage, and daily factory intake capacity."
            showErrorAlert = true
            return
        }

        isSubmitting = true
        errorMessage = nil

        let request = EstateOnboardRequestDTO(
            name: estateName.trimmingCharacters(in: .whitespacesAndNewlines),
            district: selectedDistrict,
            elevationMeters: elevation,
            totalAreaAcres: acres,
            dailyFactoryCapacityKg: capacity
        )

        do {
            let response = try await apiService.onboardEstate(request: request)
            authService.updateCurrentUserEstate(estateId: response.id)
            HapticFeedback.notification(.success)
            self.onboardingSuccess = true
            self.isSubmitting = false
        } catch let networkError as NetworkError {
            self.isSubmitting = false
            self.errorMessage = networkError.localizedDescription
            self.showErrorAlert = true
        } catch {
            self.isSubmitting = false
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    /// Signs out the active user if they want to cancel onboarding or log into an existing tenant.
    func cancelAndLogout() {
        authService.logout()
    }
}

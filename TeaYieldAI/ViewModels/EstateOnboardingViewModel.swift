import Foundation
import SwiftUI

/// Coordinates estate parameter ingestion, mathematical prior validation, and initial tenant setup.
@MainActor
final class EstateOnboardingViewModel: ObservableObject {

    @Published var estateName: String = ""
    @Published var selectedDistrict: String = ""
    @Published var elevationInput: String = ""
    @Published var totalAcresInput: String = ""
    @Published var dailyFactoryCapacityInput: String = ""

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
        return nameTrimmed.count >= 2 && nameTrimmed.count <= 150 &&
               isDistrictValid &&
               isElevationValid &&
               isAcresValid &&
               isCapacityValid
    }

    var isDistrictValid: Bool {
        !selectedDistrict.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isElevationValid: Bool {
        guard let elevation = Int(InputSanitizer.sanitizeInteger(elevationInput)) else { return false }
        return elevation >= 50 && elevation <= 2600
    }

    var isAcresValid: Bool {
        guard let acres = Double(InputSanitizer.sanitizeDecimal(totalAcresInput)) else { return false }
        return acres >= 1.0 && acres <= 50000.0
    }

    var isCapacityValid: Bool {
        guard let capacity = Double(InputSanitizer.sanitizeDecimal(dailyFactoryCapacityInput)) else { return false }
        return capacity >= 1.0 && capacity <= 200000.0
    }

    /// Retained for compatibility; does not overwrite user entered elevation values.
    func applyDistrictDefaults(_ district: SriLankanTeaDistrict) {
        // Intentionally left blank to avoid unwanted auto-suggest overrides of user inputs.
    }

    /// Dispatches the estate onboarding payload to the backend and updates the user tenant session.
    func onboardEstate() async {
        guard isFormValid else {
            errorMessage = "Please enter an estate name, valid elevation (50m - 2,600m), acreage (1 - 50,000), and factory capacity (up to 200,000 kg/day)."
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
            HapticFeedback.success()
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


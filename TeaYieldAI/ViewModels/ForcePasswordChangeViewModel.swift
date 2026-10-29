import Foundation
import SwiftUI

/// Coordinates mandatory temporary credential rotation for provisioned field supervisors.
@MainActor
final class ForcePasswordChangeViewModel: ObservableObject {

    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var passwordChangedSuccessfully: Bool = false

    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol

    init(authService: AuthServiceProtocol, apiService: APIServiceProtocol) {
        self.authService = authService
        self.apiService = apiService
    }

    /// Checks whether the entered passwords meet enterprise security standards.
    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword != currentPassword &&
        newPassword == confirmPassword
    }

    var hasMinimumLength: Bool {
        newPassword.count >= 8
    }

    var isDifferentFromCurrent: Bool {
        !newPassword.isEmpty && newPassword != currentPassword
    }

    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    /// Dispatches the password rotation request to the authentication service.
    func changePassword() async {
        guard isFormValid else {
            if currentPassword.isEmpty {
                errorMessage = "Please enter your current temporary password."
            } else if newPassword.count < 8 {
                errorMessage = "The new permanent password must contain at least 8 characters."
            } else if newPassword == currentPassword {
                errorMessage = "The new password must be different from your temporary password."
            } else if newPassword != confirmPassword {
                errorMessage = "The new passwords do not match. Please verify your confirmation entry."
            }
            showErrorAlert = true
            return
        }

        isSubmitting = true
        errorMessage = nil

        let request = PasswordChangeRequestDTO(
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        do {
            _ = try await apiService.changePassword(request: request)
            authService.completePasswordChange()
            HapticFeedback.notification(.success)
            self.passwordChangedSuccessfully = true
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

    /// Signs out the active user and returns them to the authentication gateway.
    func logout() {
        authService.logout()
    }
}

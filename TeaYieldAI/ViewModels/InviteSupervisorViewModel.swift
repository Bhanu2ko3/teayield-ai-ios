import Foundation
import SwiftUI

/// Coordinates supervisor staff provisioning and temporary credential generation for estate managers.
@MainActor
final class InviteSupervisorViewModel: ObservableObject {

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var temporaryPassword: String = ""
    @Published var phoneNumber: String = ""

    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var invitationSuccess: Bool = false
    @Published var createdSupervisor: UserProfileDTO? = nil

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        self.temporaryPassword = Self.generateTemporaryPassword()
    }

    var isFormValid: Bool {
        let nameValid = fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        let emailValid = InputSanitizer.isValidEmail(email)
        let passwordValid = temporaryPassword.count >= 8
        let phoneValid = phoneNumber.isEmpty || InputSanitizer.isValidPhoneNumber(phoneNumber)
        return nameValid && emailValid && passwordValid && phoneValid
    }

    /// Generates a human-readable high-entropy temporary password for initial supervisor dispatch.
    static func generateTemporaryPassword() -> String {
        let prefix = "TeaYield"
        let allowedChars = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
        let randomSuffix = String((0..<6).map { _ in allowedChars.randomElement()! })
        return "\(prefix)-\(randomSuffix)"
    }

    /// Regenerates the temporary password field.
    func regeneratePassword() {
        self.temporaryPassword = Self.generateTemporaryPassword()
    }

    /// Dispatches the invitation payload to the remote API.
    func inviteSupervisor() async {
        guard isFormValid else {
            if fullName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                errorMessage = "Please enter the supervisor's full legal name (at least 2 characters)."
            } else if !InputSanitizer.isValidEmail(email) {
                errorMessage = "Please enter a valid corporate email address."
            } else if temporaryPassword.count < 8 {
                errorMessage = "The temporary password must contain at least 8 characters."
            } else if !phoneNumber.isEmpty && !InputSanitizer.isValidPhoneNumber(phoneNumber) {
                errorMessage = "Please enter a valid phone number with 9 to 15 digits."
            } else {
                errorMessage = "Please verify all required fields."
            }
            showErrorAlert = true
            return
        }

        isSubmitting = true
        errorMessage = nil

        let sanitizedPhone = InputSanitizer.sanitizePhoneNumber(phoneNumber)
        let phoneParam: String? = sanitizedPhone.isEmpty ? nil : sanitizedPhone

        let request = SupervisorInviteRequestDTO(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            temporaryPassword: temporaryPassword,
            phoneNumber: phoneParam
        )

        do {
            let response = try await apiService.inviteSupervisor(request: request)
            self.createdSupervisor = response
            self.invitationSuccess = true
            self.isSubmitting = false
            HapticFeedback.success()
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

    /// Resets form state to prepare for inviting another supervisor.
    func resetForm() {
        fullName = ""
        email = ""
        phoneNumber = ""
        temporaryPassword = Self.generateTemporaryPassword()
        invitationSuccess = false
        createdSupervisor = nil
        errorMessage = nil
    }

    private func isValidEmail(_ candidate: String) -> Bool {
        InputSanitizer.isValidEmail(candidate)
    }
}


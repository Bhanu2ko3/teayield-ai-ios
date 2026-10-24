import Foundation
import SwiftUI

/// Coordinates user authentication, form validation, and biometric Face ID access.
@MainActor
final class AuthViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false

    var isBiometricAvailable: Bool {
        authService.isBiometricAvailable
    }

    var biometricType: BiometryType {
        authService.biometricType
    }

    var isFormValid: Bool {
        isValidEmail(email) && password.count >= 6
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        // Restore last entered email if persisted in Keychain
        if let lastEmail = KeychainHelper.shared.readString(forKey: KeychainHelper.Key.lastUserEmail) {
            self.email = lastEmail
        }
    }

    // MARK: - Actions

    /// Authenticates the user with email and password against the FastAPI backend.
    func login() async {
        guard isFormValid else {
            errorMessage = "Please enter a valid email address and a password with at least 6 characters."
            showErrorAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let credentials = LoginRequestDTO(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            _ = try await authService.login(credentials: credentials)
            isLoading = false
        } catch let networkError as NetworkError {
            isLoading = false
            errorMessage = networkError.localizedDescription
            showErrorAlert = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    /// Triggers local biometric Face ID or Touch ID authentication using cached Keychain tokens.
    func authenticateWithBiometrics() async {
        guard isBiometricAvailable else {
            errorMessage = "Biometric credentials are not available. Please sign in with your email and password first."
            showErrorAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.authenticateWithBiometrics()
            isLoading = false
        } catch BiometricError.userCancelled {
            // User voluntarily dismissed the Face ID prompt; no disruptive alert needed
            isLoading = false
        } catch let biometricError as BiometricError {
            isLoading = false
            errorMessage = biometricError.localizedDescription
            showErrorAlert = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    /// Signs out the active user and clears session state.
    func logout() {
        authService.logout()
        password = ""
    }

    // MARK: - Private Helpers

    private func isValidEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: candidate.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

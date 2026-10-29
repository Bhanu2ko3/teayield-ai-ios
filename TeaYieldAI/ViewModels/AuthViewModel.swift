import Foundation
import SwiftUI

/// Coordinates user authentication, form validation, manager self-registration, and biometric Face ID access.
@MainActor
final class AuthViewModel: ObservableObject {

    /// Authentication modes supported on the entry gateway.
    enum AuthMode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Register Manager"

        var id: String { rawValue }
    }

    @Published var authMode: AuthMode = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var signUpFullName: String = ""
    @Published var signUpPhoneNumber: String = ""
    @Published var signUpConfirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false

    var isBiometricAvailable: Bool {
        authService.isBiometricAvailable
    }

    var hasEnrolledBiometricCredentials: Bool {
        authService.hasEnrolledBiometricCredentials
    }

    var biometricType: BiometryType {
        authService.biometricType
    }

    var hasSignUpMinLength: Bool {
        password.count >= 8
    }

    var hasSignUpNumber: Bool {
        password.contains(where: \.isNumber)
    }

    var doSignUpPasswordsMatch: Bool {
        !password.isEmpty && !signUpConfirmPassword.isEmpty && password == signUpConfirmPassword
    }

    var isSignUpPhoneValid: Bool {
        if signUpPhoneNumber.isEmpty { return true }
        let digits = signUpPhoneNumber.filter { $0.isNumber }
        let normalized = digits.hasPrefix("0") ? String(digits.dropFirst()) : digits
        return normalized.count == 9
    }

    var fullInternationalPhoneNumber: String? {
        let digits = signUpPhoneNumber.filter { $0.isNumber }
        if digits.isEmpty { return nil }
        let normalized = digits.hasPrefix("0") ? String(digits.dropFirst()) : digits
        return "+94\(normalized)"
    }

    var isFormValid: Bool {
        switch authMode {
        case .signIn:
            return InputSanitizer.isValidEmail(email) && password.count >= 6
        case .signUp:
            let nameValid = signUpFullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
            let emailValid = InputSanitizer.isValidEmail(email)
            let passwordValid = hasSignUpMinLength && hasSignUpNumber && doSignUpPasswordsMatch
            let phoneValid = isSignUpPhoneValid
            return nameValid && emailValid && passwordValid && phoneValid
        }
    }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    /// Selects pre-configured enterprise demonstration accounts for testing and viva evaluation.
    func selectDemoProfile(role: UserRole) {
        errorMessage = nil
        switch role {
        case .fieldSupervisor:
            email = "supervisor@nuwaraeliya.estate.lk"
            password = "Password123!"
        case .estateManager:
            email = "manager@nuwaraeliya.estate.lk"
            password = "Password123!"
        }
    }

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

    /// Registers a new estate manager account with tenant administrator privileges.
    func signUpManager() async {
        guard isFormValid else {
            if signUpFullName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                errorMessage = "Please enter your full name (at least 2 characters)."
            } else if !InputSanitizer.isValidEmail(email) {
                errorMessage = "Please enter a valid email address."
            } else if !hasSignUpMinLength {
                errorMessage = "Password must contain at least 8 characters."
            } else if !hasSignUpNumber {
                errorMessage = "Password must contain at least one number."
            } else if !doSignUpPasswordsMatch {
                errorMessage = "Passwords do not match. Please verify confirmation."
            } else if !signUpPhoneNumber.isEmpty && !isSignUpPhoneValid {
                errorMessage = "Please enter a valid 9-digit mobile number."
            } else {
                errorMessage = "Please complete all required fields."
            }
            showErrorAlert = true
            return
        }

        isLoading = true
        errorMessage = nil

        let phoneParam: String? = fullInternationalPhoneNumber

        let request = ManagerSignUpRequestDTO(
            fullName: signUpFullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            phoneNumber: phoneParam
        )

        do {
            _ = try await authService.signupManager(request: request)
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

    /// Dispatches the appropriate network call according to the active auth mode.
    func submit() async {
        switch authMode {
        case .signIn:
            await login()
        case .signUp:
            await signUpManager()
        }
    }

    /// Triggers local biometric Face ID or Touch ID authentication using cached Keychain tokens.
    func authenticateWithBiometrics() async {
        guard isBiometricAvailable else {
            errorMessage = "Biometric hardware is not available on this device."
            showErrorAlert = true
            return
        }

        guard hasEnrolledBiometricCredentials else {
            errorMessage = "Please sign in with your enterprise email and password once. After your first sign in, \(biometricType.rawValue) will be activated for instant access."
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
        signUpConfirmPassword = ""
    }

    // MARK: - Private Helpers

    private func isValidEmail(_ candidate: String) -> Bool {
        InputSanitizer.isValidEmail(candidate)
    }
}

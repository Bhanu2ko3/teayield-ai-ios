import Foundation

/// Primary authentication service coordinating API requests, Keychain storage, and biometric verification.
@MainActor
final class AuthService: ObservableObject, AuthServiceProtocol {

    @Published public private(set) var currentUser: UserProfile?
    @Published public private(set) var isAuthenticated: Bool = false

    var isBiometricAvailable: Bool {
        biometricManager.canEvaluateBiometrics && keychain.readString(forKey: KeychainHelper.Key.accessToken) != nil
    }

    var biometricType: BiometryType {
        biometricManager.biometryType
    }

    private let apiService: APIServiceProtocol
    private let keychain: KeychainHelper
    private let biometricManager: BiometricAuthManager

    init(
        apiService: APIServiceProtocol,
        keychain: KeychainHelper = .shared,
        biometricManager: BiometricAuthManager = .shared
    ) {
        self.apiService = apiService
        self.keychain = keychain
        self.biometricManager = biometricManager

        _ = restoreSession()
    }

    // MARK: - AuthServiceProtocol Methods

    func login(credentials: LoginRequestDTO) async throws -> UserProfile {
        guard credentials.isValid else {
            throw NetworkError.serverError(
                statusCode: 422,
                message: "Please enter a valid email address and a password with at least 6 characters.",
                errorCode: "INVALID_INPUT_FORMAT"
            )
        }

        let tokenResponse = try await apiService.login(credentials: credentials)
        let defaultEmpId = (tokenResponse.user.role == "estate_manager") ? "MGR-082" : "SUP-402"
        let domainUser = tokenResponse.user.toDomain(employeeId: defaultEmpId)

        // Securely persist credentials in the device Keychain
        _ = keychain.saveString(tokenResponse.accessToken, forKey: KeychainHelper.Key.accessToken)
        _ = keychain.saveCodable(domainUser, forKey: KeychainHelper.Key.currentUser)
        _ = keychain.saveString(credentials.email, forKey: KeychainHelper.Key.lastUserEmail)

        self.apiService.authToken = tokenResponse.accessToken
        self.currentUser = domainUser
        self.isAuthenticated = true

        return domainUser
    }

    func authenticateWithBiometrics() async throws -> UserProfile {
        guard let cachedToken = keychain.readString(forKey: KeychainHelper.Key.accessToken),
              let cachedUser = keychain.readCodable(UserProfile.self, forKey: KeychainHelper.Key.currentUser) else {
            throw BiometricError.failed("No stored credentials found. Please log in with email and password first.")
        }

        let prompt = "Authenticate with \(biometricType.rawValue) to unlock TeaYield AI"
        let success = try await biometricManager.authenticateWithPasscodeFallback(reason: prompt)

        if success {
            self.apiService.authToken = cachedToken
            self.currentUser = cachedUser
            self.isAuthenticated = true
            return cachedUser
        } else {
            throw BiometricError.failed("Biometric authentication was unsuccessful.")
        }
    }

    func logout() {
        keychain.delete(forKey: KeychainHelper.Key.accessToken)
        keychain.delete(forKey: KeychainHelper.Key.currentUser)

        apiService.authToken = nil
        self.currentUser = nil
        self.isAuthenticated = false
    }

    func restoreSession() -> Bool {
        guard let token = keychain.readString(forKey: KeychainHelper.Key.accessToken),
              let user = keychain.readCodable(UserProfile.self, forKey: KeychainHelper.Key.currentUser) else {
            return false
        }

        apiService.authToken = token
        self.currentUser = user
        self.isAuthenticated = true
        return true
    }
}

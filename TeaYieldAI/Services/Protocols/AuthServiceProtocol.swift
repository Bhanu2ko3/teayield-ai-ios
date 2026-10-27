import Foundation

/// Defines the contract for user authentication, biometric unlock, and secure token lifecycle.
@MainActor
protocol AuthServiceProtocol: AnyObject {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    var isBiometricAvailable: Bool { get }
    var hasEnrolledBiometricCredentials: Bool { get }
    var biometricType: BiometryType { get }

    /// Authenticates with email and password credentials via the remote API.
    func login(credentials: LoginRequestDTO) async throws -> UserProfile

    /// Performs local biometric unlock using cached credentials and restores session.
    func authenticateWithBiometrics() async throws -> UserProfile

    /// Clears the active session and purges stored Keychain tokens.
    func logout()

    /// Restores any previously persisted session from the Keychain upon app launch.
    func restoreSession() -> Bool
}

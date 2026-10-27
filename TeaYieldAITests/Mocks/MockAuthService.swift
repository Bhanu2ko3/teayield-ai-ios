import Foundation
@testable import TeaYieldAI

/// Test double simulating user authentication, biometric unlock, and session state.
@MainActor
final class MockAuthService: AuthServiceProtocol {

    var currentUser: UserProfile?
    var isAuthenticated: Bool { currentUser != nil }
    var isBiometricAvailable: Bool = true
    var hasEnrolledBiometricCredentials: Bool = true
    var biometricType: BiometryType = .faceID

    var shouldFailLogin: Bool = false
    var shouldFailBiometrics: Bool = false
    var errorToThrow: Error = NetworkError.unauthorized

    private(set) var loginCallCount: Int = 0
    private(set) var biometricCallCount: Int = 0
    private(set) var logoutCallCount: Int = 0
    private(set) var restoreSessionCallCount: Int = 0

    init(initialUser: UserProfile? = nil) {
        self.currentUser = initialUser
    }

    func login(credentials: LoginRequestDTO) async throws -> UserProfile {
        loginCallCount += 1
        if shouldFailLogin {
            throw errorToThrow
        }
        let user = UserProfile(
            id: UUID(),
            email: credentials.username,
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
        self.currentUser = user
        return user
    }

    func authenticateWithBiometrics() async throws -> UserProfile {
        biometricCallCount += 1
        if shouldFailBiometrics {
            throw errorToThrow
        }
        if let existing = currentUser {
            return existing
        }
        let user = UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
        self.currentUser = user
        return user
    }

    func logout() {
        logoutCallCount += 1
        currentUser = nil
    }

    func restoreSession() -> Bool {
        restoreSessionCallCount += 1
        return currentUser != nil
    }
}

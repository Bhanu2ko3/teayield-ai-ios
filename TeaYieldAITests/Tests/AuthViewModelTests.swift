import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Authentication ViewModel Unit Tests")
@MainActor
struct AuthViewModelTests {

    @Test("Verifies form validation constraints on email and password length")
    func formValidation() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        // Invalid: Empty fields
        #expect(viewModel.isFormValid == false)

        // Invalid: Malformed email
        viewModel.email = "invalid-email"
        viewModel.password = "Secret123"
        #expect(viewModel.isFormValid == false)

        // Invalid: Password too short (< 6 chars)
        viewModel.email = "officer@pedro.lk"
        viewModel.password = "12345"
        #expect(viewModel.isFormValid == false)

        // Valid: Compliant email and length >= 6
        viewModel.email = "officer@pedro.lk"
        viewModel.password = "SecurePass123"
        #expect(viewModel.isFormValid == true)
    }

    @Test("Verifies selecting demo profile autofills enterprise credentials")
    func demoProfileSelection() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.selectDemoProfile(role: .fieldSupervisor)
        #expect(viewModel.email.contains("supervisor"))
        #expect(viewModel.password.count >= 6)
        #expect(viewModel.isFormValid == true)

        viewModel.selectDemoProfile(role: .estateManager)
        #expect(viewModel.email.contains("manager"))
        #expect(viewModel.password.count >= 6)
        #expect(viewModel.isFormValid == true)
    }

    @Test("Verifies successful login flow authenticates user session")
    func loginSuccess() async {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.selectDemoProfile(role: .fieldSupervisor)
        await viewModel.login()

        #expect(auth.loginCallCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showErrorAlert == false)
        #expect(auth.isAuthenticated == true)
    }

    @Test("Verifies failed login displays descriptive error alert")
    func loginFailure() async {
        let auth = MockAuthService()
        auth.shouldFailLogin = true
        let viewModel = AuthViewModel(authService: auth)

        viewModel.email = "wrong@pedro.lk"
        viewModel.password = "WrongPassword"
        await viewModel.login()

        #expect(auth.loginCallCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.showErrorAlert == true)
    }

    @Test("Verifies biometric Face ID authentication flow")
    func biometricAuthentication() async {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        await viewModel.authenticateWithBiometrics()

        #expect(auth.biometricCallCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(auth.isAuthenticated == true)
    }

    @Test("Verifies logout clears password and active session")
    func logout() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.password = "SecretPass"
        viewModel.logout()

        #expect(auth.logoutCallCount == 1)
        #expect(viewModel.password == "")
        #expect(auth.isAuthenticated == false)
    }
}

#else
import XCTest

@MainActor
final class AuthViewModelTests: XCTestCase {

    func testFormValidation() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        XCTAssertFalse(viewModel.isFormValid)

        viewModel.email = "invalid-email"
        viewModel.password = "Secret123"
        XCTAssertFalse(viewModel.isFormValid)

        viewModel.email = "officer@pedro.lk"
        viewModel.password = "12345"
        XCTAssertFalse(viewModel.isFormValid)

        viewModel.email = "officer@pedro.lk"
        viewModel.password = "SecurePass123"
        XCTAssertTrue(viewModel.isFormValid)
    }

    func testDemoProfileSelection() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.selectDemoProfile(role: .fieldSupervisor)
        XCTAssertTrue(viewModel.email.contains("supervisor"))
        XCTAssertGreaterThanOrEqual(viewModel.password.count, 6)
        XCTAssertTrue(viewModel.isFormValid)

        viewModel.selectDemoProfile(role: .estateManager)
        XCTAssertTrue(viewModel.email.contains("manager"))
        XCTAssertGreaterThanOrEqual(viewModel.password.count, 6)
        XCTAssertTrue(viewModel.isFormValid)
    }

    func testLoginSuccess() async {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.selectDemoProfile(role: .fieldSupervisor)
        await viewModel.login()

        XCTAssertEqual(auth.loginCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showErrorAlert)
        XCTAssertTrue(auth.isAuthenticated)
    }

    func testLoginFailure() async {
        let auth = MockAuthService()
        auth.shouldFailLogin = true
        let viewModel = AuthViewModel(authService: auth)

        viewModel.email = "wrong@pedro.lk"
        viewModel.password = "WrongPassword"
        await viewModel.login()

        XCTAssertEqual(auth.loginCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.showErrorAlert)
    }

    func testBiometricAuthentication() async {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        await viewModel.authenticateWithBiometrics()

        XCTAssertEqual(auth.biometricCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(auth.isAuthenticated)
    }

    func testLogout() {
        let auth = MockAuthService()
        let viewModel = AuthViewModel(authService: auth)

        viewModel.password = "SecretPass"
        viewModel.logout()

        XCTAssertEqual(auth.logoutCallCount, 1)
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(auth.isAuthenticated)
    }
}
#endif

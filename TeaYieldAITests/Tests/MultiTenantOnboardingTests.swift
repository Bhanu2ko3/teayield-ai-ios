import Foundation
import Testing
@testable import TeaYieldAI

/// Comprehensive test suite validating multi-tenant self-service onboarding,
/// mathematical prior ingestion, mandatory password rotation, and supervisor delegation.
@MainActor
struct MultiTenantOnboardingTests {

    // MARK: - Component 1: Manager Self-Service Sign Up Tests

    @Test("Manager sign up form rejects invalid email and short passwords")
    func testManagerSignUpValidation() {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.authMode = .signUp

        // Empty state
        viewModel.signUpFullName = ""
        viewModel.email = ""
        viewModel.password = ""
        #expect(viewModel.isFormValid == false)

        // Invalid email
        viewModel.signUpFullName = "Bhanuka Bandara"
        viewModel.email = "not-an-email"
        viewModel.password = "SecurePass123!"
        #expect(viewModel.isFormValid == false)

        // Password shorter than 8 characters
        viewModel.signUpFullName = "Bhanuka Bandara"
        viewModel.email = "manager@plantation.lk"
        viewModel.password = "Short1"
        #expect(viewModel.isFormValid == false)

        // Valid payload
        viewModel.signUpFullName = "Bhanuka Bandara"
        viewModel.email = "manager@plantation.lk"
        viewModel.password = "SecurePass123!"
        #expect(viewModel.isFormValid == true)
    }

    @Test("Manager successful sign up saves token and initializes user with unassigned estate")
    func testManagerSuccessfulSignUp() async {
        let authService = MockAuthService()
        let viewModel = AuthViewModel(authService: authService)
        viewModel.authMode = .signUp
        viewModel.signUpFullName = "Bhanuka Bandara"
        viewModel.email = "manager@pedro.lk"
        viewModel.password = "SecurePass123!"

        await viewModel.signUpManager()

        #expect(authService.signupCallCount == 1)
        #expect(authService.isAuthenticated == true)
        #expect(authService.currentUser != nil)
        #expect(authService.currentUser?.isManager == true)
        #expect(authService.currentUser?.estateId == nil)
        #expect(authService.currentUser?.hasOnboardedEstate == false)
    }

    // MARK: - Component 2: Estate Onboarding Wizard Tests

    @Test("Estate onboarding validates elevation, acreage, and factory intake boundaries")
    func testEstateOnboardingPriorValidation() {
        let authService = MockAuthService()
        let apiService = MockAPIService()
        let viewModel = EstateOnboardingViewModel(authService: authService, apiService: apiService)

        // Initial default is valid
        viewModel.estateName = "Pedro Estate"
        viewModel.elevationInput = "1868"
        viewModel.totalAcresInput = "450.0"
        viewModel.dailyFactoryCapacityInput = "25000.0"
        #expect(viewModel.isFormValid == true)

        // Elevation below Sri Lankan minimum (50m)
        viewModel.elevationInput = "20"
        #expect(viewModel.isFormValid == false)

        // Elevation above Pidurutalagala peak (2600m)
        viewModel.elevationInput = "3000"
        #expect(viewModel.isFormValid == false)
        viewModel.elevationInput = "1868"

        // Acreage out of bounds
        viewModel.totalAcresInput = "0"
        #expect(viewModel.isFormValid == false)
        viewModel.totalAcresInput = "450.0"

        // Negative factory capacity
        viewModel.dailyFactoryCapacityInput = "-100"
        #expect(viewModel.isFormValid == false)
    }

    @Test("Submitting estate parameters binds estate identifier and unlocks operational state")
    func testEstateOnboardingSubmission() async {
        let authService = MockAuthService(initialUser: UserProfile(
            id: UUID(),
            email: "manager@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .estateManager,
            employeeId: "MGR-082",
            estateId: nil
        ))
        let apiService = MockAPIService()
        let expectedEstateId = UUID()
        apiService.mockEstate = EstateResponseDTO(
            id: expectedEstateId,
            name: "Highland Valley Estate",
            district: "Nuwara Eliya",
            elevationMeters: 1868,
            totalAreaAcres: 450.0,
            dailyFactoryCapacityKg: 25000.0,
            createdAt: "2026-01-01T00:00:00Z",
            updatedAt: "2026-01-01T00:00:00Z"
        )

        let viewModel = EstateOnboardingViewModel(authService: authService, apiService: apiService)
        viewModel.estateName = "Highland Valley Estate"
        viewModel.selectedDistrict = "Nuwara Eliya"
        viewModel.elevationInput = "1868"
        viewModel.totalAcresInput = "450.0"
        viewModel.dailyFactoryCapacityInput = "25000.0"

        await viewModel.onboardEstate()

        #expect(viewModel.onboardingSuccess == true)
        #expect(authService.currentUser?.estateId != nil)
        #expect(authService.currentUser?.hasOnboardedEstate == true)
    }

    // MARK: - Component 3: Mandatory Password Rotation Tests

    @Test("Password rotation enforces minimum 8 characters and mismatch with temporary credential")
    func testPasswordRotationValidation() {
        let authService = MockAuthService()
        let apiService = MockAPIService()
        let viewModel = ForcePasswordChangeViewModel(authService: authService, apiService: apiService)

        viewModel.currentPassword = "TempPassword123!"
        viewModel.newPassword = "TempPassword123!" // Same as current
        viewModel.confirmPassword = "TempPassword123!"
        #expect(viewModel.isFormValid == false)

        viewModel.newPassword = "Short1" // Less than 8 chars
        viewModel.confirmPassword = "Short1"
        #expect(viewModel.isFormValid == false)

        viewModel.newPassword = "PermanentPassword99!"
        viewModel.confirmPassword = "MismatchedPassword99!" // Do not match
        #expect(viewModel.isFormValid == false)

        viewModel.newPassword = "PermanentPassword99!"
        viewModel.confirmPassword = "PermanentPassword99!"
        #expect(viewModel.isFormValid == true)
    }

    @Test("Successful password rotation clears mustChangePassword flag")
    func testPasswordRotationExecution() async {
        let authService = MockAuthService(initialUser: UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Kasun Jayawardena",
            role: .fieldSupervisor,
            employeeId: "SUP-001",
            estateId: UUID(),
            mustChangePassword: true
        ))
        let apiService = MockAPIService()
        let viewModel = ForcePasswordChangeViewModel(authService: authService, apiService: apiService)

        viewModel.currentPassword = "TempPassword123!"
        viewModel.newPassword = "PermanentPassword99!"
        viewModel.confirmPassword = "PermanentPassword99!"

        await viewModel.changePassword()

        #expect(viewModel.passwordChangedSuccessfully == true)
        #expect(authService.currentUser?.mustChangePassword == false)
    }

    // MARK: - Component 4: Supervisor Delegation Tests

    @Test("Supervisor delegation generates secure temporary password and dispatches invitation")
    func testSupervisorDelegationWorkflow() async {
        let apiService = MockAPIService()
        let viewModel = InviteSupervisorViewModel(apiService: apiService)

        #expect(viewModel.temporaryPassword.count >= 8)
        #expect(viewModel.temporaryPassword.hasPrefix("TeaYield-"))

        viewModel.fullName = "Nuwan Perera"
        viewModel.email = "nuwan@pedro.estate.lk"
        viewModel.phoneNumber = "+94771234567"

        #expect(viewModel.isFormValid == true)

        await viewModel.inviteSupervisor()

        #expect(viewModel.invitationSuccess == true)
        #expect(viewModel.createdSupervisor != nil)
        #expect(viewModel.createdSupervisor?.role == "field_supervisor")
    }
}

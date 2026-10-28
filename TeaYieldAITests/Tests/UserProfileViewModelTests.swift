import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("User Profile ViewModel Unit Tests")
@MainActor
struct UserProfileViewModelTests {

    private func createSampleOfficer() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Kusal Bandara",
            role: .fieldSupervisor,
            employeeId: "SUP-402",
            estateId: UUID(uuidString: "3b241101-5231-4822-a982-f87c126d4001")!
        )
    }

    @Test("Verifies officer identity derivation and avatar initials")
    func officerIdentityDerivation() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        #expect(viewModel.fullName == "Kusal Bandara")
        #expect(viewModel.employeeId == "SUP-402")
        #expect(viewModel.email == "supervisor@pedro.lk")
        #expect(viewModel.roleTitle == "Field Superintendent")
        #expect(viewModel.avatarInitials == "KB")
        #expect(viewModel.isManager == false)
    }

    @Test("Verifies loading agronomic telemetry from repositories")
    func profileTelemetryLoading() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()

        let sampleRecord = HarvestRecord(
            id: UUID(),
            fieldId: UUID(),
            pluckerId: "EMP-4012",
            pluckerName: "K. Meenakshi",
            grossWeightKg: 28.5,
            tareWeightKg: 1.5,
            netWeightKg: 27.0,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: true
        )
        try? await harvestRepo.saveRecord(sampleRecord)

        let viewModel = UserProfileViewModel(
            authService: auth,
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo
        )

        await viewModel.loadProfileTelemetry()

        #expect(viewModel.cachedRecordsCount == 1)
        #expect(viewModel.totalHarvestedWeightKg == 27.0)
        #expect(viewModel.averageFineLeafPercentage == 88.0)
    }

    @Test("Verifies cloud profile refresh success flow")
    func refreshProfileFromCloudSuccess() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        api.mockUserProfile = UserProfileDTO(
            id: user.id,
            estateId: user.estateId,
            email: "supervisor@pedro.lk",
            fullName: "Kusal Bandara",
            role: "field_supervisor",
            phoneNumber: "+94771234567",
            createdAt: "2026-01-01T00:00:00Z",
            updatedAt: "2026-10-28T00:00:00Z"
        )

        let viewModel = UserProfileViewModel(
            authService: auth,
            apiService: api
        )

        await viewModel.refreshProfileFromCloud()

        #expect(viewModel.refreshSuccessMessage != nil)
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.showErrorAlert == false)
    }

    @Test("Verifies cloud profile refresh error handling")
    func refreshProfileFromCloudFailure() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()
        api.shouldFailRequests = true
        api.simulatedNetworkError = NetworkError.connectionFailure("Cloudflare gateway timed out")

        let viewModel = UserProfileViewModel(
            authService: auth,
            apiService: api
        )

        await viewModel.refreshProfileFromCloud()

        #expect(viewModel.showErrorAlert == true)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isRefreshing == false)
    }

    @Test("Verifies logout delegates to authentication service")
    func logout() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        viewModel.logout()

        #expect(auth.logoutCallCount == 1)
        #expect(auth.currentUser == nil)
    }

    @Test("Verifies saving and removing user profile image")
    func profileImageSaveAndRemove() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        let testImage = renderer.image { ctx in
            UIColor.green.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
        }

        viewModel.saveProfileImage(testImage)
        #expect(viewModel.profileImage != nil)

        viewModel.removeProfileImage()
        #expect(viewModel.profileImage == nil)
    }
}

#else
import XCTest

@MainActor
final class UserProfileViewModelTests: XCTestCase {

    private func createSampleOfficer() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Kusal Bandara",
            role: .fieldSupervisor,
            employeeId: "SUP-402",
            estateId: UUID(uuidString: "3b241101-5231-4822-a982-f87c126d4001")!
        )
    }

    func testOfficerIdentityDerivation() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        XCTAssertEqual(viewModel.fullName, "Kusal Bandara")
        XCTAssertEqual(viewModel.employeeId, "SUP-402")
        XCTAssertEqual(viewModel.email, "supervisor@pedro.lk")
        XCTAssertEqual(viewModel.roleTitle, "Field Superintendent")
        XCTAssertEqual(viewModel.avatarInitials, "KB")
        XCTAssertFalse(viewModel.isManager)
    }

    func testProfileTelemetryLoading() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()

        let sampleRecord = HarvestRecord(
            id: UUID(),
            fieldId: UUID(),
            pluckerId: "EMP-4012",
            pluckerName: "K. Meenakshi",
            grossWeightKg: 28.5,
            tareWeightKg: 1.5,
            netWeightKg: 27.0,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: true
        )
        try? await harvestRepo.saveRecord(sampleRecord)

        let viewModel = UserProfileViewModel(
            authService: auth,
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo
        )

        await viewModel.loadProfileTelemetry()

        XCTAssertEqual(viewModel.cachedRecordsCount, 1)
        XCTAssertEqual(viewModel.totalHarvestedWeightKg, 27.0)
        XCTAssertEqual(viewModel.averageFineLeafPercentage, 88.0)
    }

    func testRefreshProfileFromCloudSuccess() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        api.mockUserProfile = UserProfileDTO(
            id: user.id,
            estateId: user.estateId,
            email: "supervisor@pedro.lk",
            fullName: "Kusal Bandara",
            role: "field_supervisor",
            phoneNumber: "+94771234567",
            createdAt: "2026-01-01T00:00:00Z",
            updatedAt: "2026-10-28T00:00:00Z"
        )

        let viewModel = UserProfileViewModel(
            authService: auth,
            apiService: api
        )

        await viewModel.refreshProfileFromCloud()

        XCTAssertNotNil(viewModel.refreshSuccessMessage)
        XCTAssertFalse(viewModel.isRefreshing)
        XCTAssertFalse(viewModel.showErrorAlert)
    }

    func testRefreshProfileFromCloudFailure() async {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()
        api.shouldFailRequests = true
        api.simulatedNetworkError = NetworkError.connectionFailure("Cloudflare gateway timed out")

        let viewModel = UserProfileViewModel(
            authService: auth,
            apiService: api
        )

        await viewModel.refreshProfileFromCloud()

        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isRefreshing)
    }

    func testLogout() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        viewModel.logout()

        XCTAssertEqual(auth.logoutCallCount, 1)
        XCTAssertNil(auth.currentUser)
    }

    func testProfileImageSaveAndRemove() {
        let user = createSampleOfficer()
        let auth = MockAuthService(initialUser: user)
        let viewModel = UserProfileViewModel(authService: auth)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        let testImage = renderer.image { ctx in
            UIColor.green.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
        }

        viewModel.saveProfileImage(testImage)
        XCTAssertNotNil(viewModel.profileImage)

        viewModel.removeProfileImage()
        XCTAssertNil(viewModel.profileImage)
    }
}
#endif


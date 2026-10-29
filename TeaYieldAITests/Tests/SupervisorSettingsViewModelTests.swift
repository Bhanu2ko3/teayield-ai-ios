import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Supervisor Settings ViewModel Unit Tests")
@MainActor
struct SupervisorSettingsViewModelTests {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
    }

    @Test("Verifies officer profile and avatar initials derivation")
    func officerIdentityFormatting() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        #expect(viewModel.officerName == "Bhanuka Bandara")
        #expect(viewModel.officerEmployeeId == "SUP-082")
        #expect(viewModel.officerEmail == "supervisor@pedro.lk")
        #expect(viewModel.avatarInitials == "BB")
        #expect(viewModel.isAccountVerified == true)
    }

    @Test("Verifies loading cached division statistics from repositories")
    func loadCachedDetails() async {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()

        let sampleField = TeaField(
            id: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            acreage: 4.5,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.965,
            centroidLongitude: 80.793,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])

        let sampleRecord = HarvestRecord(
            id: UUID(),
            fieldId: sampleField.id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 20.0,
            tareWeightKg: 1.5,
            netWeightKg: 18.5,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [sampleRecord])

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        await viewModel.loadCachedDetails()

        #expect(viewModel.cachedFieldsCount == 1)
        #expect(viewModel.cachedRecordsCount == 1)
        #expect(viewModel.divisionAssignmentName.contains("Pedro Upper Division"))
    }

    @Test("Verifies manual sync execution from settings panel")
    func manualSyncTrigger() async {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        sync.stubbedSyncResult = SyncResult(
            processedCount: 2,
            failedCount: 0,
            statusMessage: "Synced 2 records successfully.",
            timestamp: Date()
        )

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        await viewModel.triggerManualSync()

        #expect(sync.syncPendingRecordsCallCount == 1)
        #expect(viewModel.isSyncing == false)
        #expect(viewModel.syncStatusMessage != nil)
    }

    @Test("Verifies logout delegates to authentication service")
    func logout() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        viewModel.logout()

        #expect(auth.logoutCallCount == 1)
        #expect(auth.currentUser == nil)
    }

    @Test("Verifies switching theme mode updates view model state and persistence")
    func themeSelection() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        viewModel.setThemeMode(.dark)
        #expect(viewModel.selectedThemeMode == .dark)
        #expect(UserDefaults.standard.string(forKey: "appThemeMode") == AppThemeMode.dark.rawValue)

        viewModel.setThemeMode(.light)
        #expect(viewModel.selectedThemeMode == .light)
        #expect(UserDefaults.standard.string(forKey: "appThemeMode") == AppThemeMode.light.rawValue)

        viewModel.setThemeMode(.system)
        #expect(viewModel.selectedThemeMode == .system)
        #expect(UserDefaults.standard.string(forKey: "appThemeMode") == AppThemeMode.system.rawValue)
    }
}

#else
import XCTest

@MainActor
final class SupervisorSettingsViewModelTests: XCTestCase {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
    }

    func testOfficerIdentityFormatting() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        XCTAssertEqual(viewModel.officerName, "Bhanuka Bandara")
        XCTAssertEqual(viewModel.officerEmployeeId, "SUP-082")
        XCTAssertEqual(viewModel.officerEmail, "supervisor@pedro.lk")
        XCTAssertEqual(viewModel.avatarInitials, "BB")
        XCTAssertTrue(viewModel.isAccountVerified)
    }

    func testLoadCachedDetails() async {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()

        let sampleField = TeaField(
            id: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            acreage: 4.5,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.965,
            centroidLongitude: 80.793,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])

        let sampleRecord = HarvestRecord(
            id: UUID(),
            fieldId: sampleField.id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 20.0,
            tareWeightKg: 1.5,
            netWeightKg: 18.5,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [sampleRecord])

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        await viewModel.loadCachedDetails()

        XCTAssertEqual(viewModel.cachedFieldsCount, 1)
        XCTAssertEqual(viewModel.cachedRecordsCount, 1)
        XCTAssertTrue(viewModel.divisionAssignmentName.contains("Pedro Upper Division"))
    }

    func testManualSyncTrigger() async {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        sync.stubbedSyncResult = SyncResult(
            processedCount: 2,
            failedCount: 0,
            statusMessage: "Synced 2 records successfully.",
            timestamp: Date()
        )

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        await viewModel.triggerManualSync()

        XCTAssertEqual(sync.syncPendingRecordsCallCount, 1)
        XCTAssertFalse(viewModel.isSyncing)
        XCTAssertNotNil(viewModel.syncStatusMessage)
    }

    func testLogout() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        viewModel.logout()

        XCTAssertEqual(auth.logoutCallCount, 1)
        XCTAssertNil(auth.currentUser)
    }

    func testThemeSelection() {
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let sync = MockSyncManager()
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()

        let viewModel = SupervisorSettingsViewModel(
            authService: auth,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo
        )

        viewModel.setThemeMode(.dark)
        XCTAssertEqual(viewModel.selectedThemeMode, .dark)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appThemeMode"), AppThemeMode.dark.rawValue)

        viewModel.setThemeMode(.light)
        XCTAssertEqual(viewModel.selectedThemeMode, .light)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appThemeMode"), AppThemeMode.light.rawValue)

        viewModel.setThemeMode(.system)
        XCTAssertEqual(viewModel.selectedThemeMode, .system)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "appThemeMode"), AppThemeMode.system.rawValue)
    }
}
#endif

import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Today Tasks ViewModel Unit Tests")
@MainActor
struct TodayTasksViewModelTests {

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

    private func createSampleDailyTasksDTO(estateId: UUID) -> DailySupervisorTasksResponseDTO {
        DailySupervisorTasksResponseDTO(
            scheduleDate: "2026-10-28",
            dayIndex: 1,
            assignedFields: [
                AssignedFieldTaskDTO(
                    fieldId: UUID(),
                    fieldName: "Pedro Upper Division",
                    blockCode: "PED-BLK-A",
                    priorityScore: 0.95,
                    predictedYieldKg: 850.0,
                    recommendedPluckers: 8,
                    currentNdvi: 0.82,
                    daysSinceLastHarvest: 12,
                    centroidLat: 6.9650,
                    centroidLon: 80.7930
                ),
                AssignedFieldTaskDTO(
                    fieldId: UUID(),
                    fieldName: "Lovers Leap Plateau",
                    blockCode: "PED-BLK-B",
                    priorityScore: 0.88,
                    predictedYieldKg: 620.0,
                    recommendedPluckers: 6,
                    currentNdvi: 0.79,
                    daysSinceLastHarvest: 10,
                    centroidLat: 6.9630,
                    centroidLon: 80.7950
                )
            ]
        )
    }

    @Test("Verifies task loading and progress ratio calculation")
    func loadTasksSuccess() async {
        let api = MockAPIService()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        api.mockDailyTasksResponse = createSampleDailyTasksDTO(estateId: user.estateId)

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        #expect(viewModel.tasks.count == 2)
        #expect(viewModel.isOffline == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.totalTargetKg == 1470.0) // 850 + 620
        #expect(viewModel.assignedPluckersTotal == 14) // 8 + 6
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Verifies offline fallback mode when network connection drops")
    func offlineFallback() async {
        let api = MockAPIService()
        api.shouldFailRequests = true
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        #expect(viewModel.isOffline == true)
        #expect(viewModel.isLoading == false)
    }

    @Test("Verifies manual sync execution and status updates")
    func manualSync() async {
        let api = MockAPIService()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        sync.stubbedSyncResult = SyncResult(
            processedCount: 3,
            failedCount: 0,
            statusMessage: "Synced 3 records successfully.",
            timestamp: Date()
        )

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.triggerManualSync()

        #expect(sync.syncPendingRecordsCallCount == 1)
        #expect(viewModel.isSyncing == false)
        #expect(viewModel.statusBannerMessage?.contains("Synced 3 records") == true)
    }

    @Test("Verifies unauthenticated state prompts login error")
    func unauthenticatedState() async {
        let api = MockAPIService()
        let auth = MockAuthService(initialUser: nil)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        #expect(viewModel.showErrorAlert == true)
        #expect(viewModel.errorMessage?.contains("log in") == true)
    }
}

#else
import XCTest

@MainActor
final class TodayTasksViewModelTests: XCTestCase {

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

    private func createSampleDailyTasksDTO(estateId: UUID) -> DailySupervisorTasksResponseDTO {
        DailySupervisorTasksResponseDTO(
            scheduleDate: "2026-10-28",
            dayIndex: 1,
            assignedFields: [
                AssignedFieldTaskDTO(
                    fieldId: UUID(),
                    fieldName: "Pedro Upper Division",
                    blockCode: "PED-BLK-A",
                    priorityScore: 0.95,
                    predictedYieldKg: 850.0,
                    recommendedPluckers: 8,
                    currentNdvi: 0.82,
                    daysSinceLastHarvest: 12,
                    centroidLat: 6.9650,
                    centroidLon: 80.7930
                ),
                AssignedFieldTaskDTO(
                    fieldId: UUID(),
                    fieldName: "Lovers Leap Plateau",
                    blockCode: "PED-BLK-B",
                    priorityScore: 0.88,
                    predictedYieldKg: 620.0,
                    recommendedPluckers: 6,
                    currentNdvi: 0.79,
                    daysSinceLastHarvest: 10,
                    centroidLat: 6.9630,
                    centroidLon: 80.7950
                )
            ]
        )
    }

    func testLoadTasksSuccess() async throws {
        let api = MockAPIService()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        api.mockDailyTasksResponse = createSampleDailyTasksDTO(estateId: user.estateId)

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        XCTAssertEqual(viewModel.tasks.count, 2)
        XCTAssertFalse(viewModel.isOffline)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.totalTargetKg, 1470.0)
        XCTAssertEqual(viewModel.assignedPluckersTotal, 14)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testOfflineFallback() async throws {
        let api = MockAPIService()
        api.shouldFailRequests = true
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        XCTAssertTrue(viewModel.isOffline)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testManualSync() async throws {
        let api = MockAPIService()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        sync.stubbedSyncResult = SyncResult(
            processedCount: 3,
            failedCount: 0,
            statusMessage: "Synced 3 records successfully.",
            timestamp: Date()
        )

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.triggerManualSync()

        XCTAssertEqual(sync.syncPendingRecordsCallCount, 1)
        XCTAssertFalse(viewModel.isSyncing)
        XCTAssertTrue(viewModel.statusBannerMessage?.contains("Synced 3 records") == true)
    }

    func testUnauthenticatedState() async throws {
        let api = MockAPIService()
        let auth = MockAuthService(initialUser: nil)
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let location = MockLocationService()

        let viewModel = TodayTasksViewModel(
            apiService: api,
            syncManager: sync,
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            locationService: location
        )

        await viewModel.loadTodayTasks()

        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertTrue(viewModel.errorMessage?.contains("log in") == true)
    }
}
#endif

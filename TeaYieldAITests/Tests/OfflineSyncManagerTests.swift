import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Offline Store-and-Forward Sync Manager Unit Tests")
@MainActor
struct OfflineSyncManagerTests {

    private func createTestRecord(id: UUID = UUID(), isSynced: Bool = false, fineLeafRatio: Double = 0.88) -> HarvestRecord {
        HarvestRecord(
            id: id,
            fieldId: UUID(),
            pluckerId: "PLK-019",
            pluckerName: "Sita Kumari",
            grossWeightKg: 24.5,
            tareWeightKg: 1.5,
            netWeightKg: 23.0,
            fineLeafRatio: fineLeafRatio,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: isSynced
        )
    }

    @Test("Verifies sync throws connectionFailure when device is offline")
    func syncThrowsWhenOffline() async {
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository()
        let network = MockNetworkMonitor(isConnected: false)

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        do {
            _ = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")
            #expect(Bool(false), "Expected connection failure error to be thrown")
        } catch let NetworkError.connectionFailure(message) {
            #expect(message.contains("offline"))
        } catch {
            #expect(Bool(false), "Unexpected error type thrown: \(error)")
        }
    }

    @Test("Verifies sync returns early when repository queue is empty")
    func syncEmptyQueue() async throws {
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [])
        let network = MockNetworkMonitor(isConnected: true)

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        #expect(result.processedCount == 0)
        #expect(result.failedCount == 0)
        #expect(api.recordedSyncBatches.isEmpty)
    }

    @Test("Verifies successful batch synchronization marks acknowledged records as synced")
    func syncSuccessBatch() async throws {
        let record1 = createTestRecord()
        let record2 = createTestRecord()
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [record1, record2])
        let network = MockNetworkMonitor(isConnected: true)

        api.mockSyncResponse = HarvestSyncResponseDTO(
            processedRecords: 2,
            failedRecords: 0,
            status: "success",
            syncedIds: [record1.id.uuidString, record2.id.uuidString]
        )

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        #expect(result.processedCount == 2)
        #expect(result.failedCount == 0)
        #expect(api.recordedSyncBatches.count == 1)
        #expect(harvestRepo.markedSyncedIds.count == 2)

        // Verify local store records now reflect isSynced = true
        let unsynced = try await harvestRepo.fetchUnsyncedRecords()
        #expect(unsynced.isEmpty)
    }

    @Test("Verifies partial sync failure marks only accepted records as synced")
    func syncPartialFailure() async throws {
        let validRecord = createTestRecord()
        let invalidRecord = createTestRecord()
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [validRecord, invalidRecord])
        let network = MockNetworkMonitor(isConnected: true)

        // Server rejects invalidRecord due to PostGIS ST_Contains boundary mismatch
        api.mockSyncResponse = HarvestSyncResponseDTO(
            processedRecords: 1,
            failedRecords: 1,
            status: "partial_success",
            syncedIds: [validRecord.id.uuidString]
        )

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        #expect(result.processedCount == 1)
        #expect(result.failedCount == 1)
        #expect(harvestRepo.markedSyncedIds.count == 1)
        #expect(harvestRepo.markedSyncedIds.first == validRecord.id)

        // Invalid record remains in unsynced queue for supervisor correction
        let unsynced = try await harvestRepo.fetchUnsyncedRecords()
        #expect(unsynced.count == 1)
        #expect(unsynced.first?.id == invalidRecord.id)
    }
}

#else
import XCTest

@MainActor
final class OfflineSyncManagerTests: XCTestCase {

    private func createTestRecord(id: UUID = UUID(), isSynced: Bool = false, fineLeafRatio: Double = 0.88) -> HarvestRecord {
        HarvestRecord(
            id: id,
            fieldId: UUID(),
            pluckerId: "PLK-019",
            pluckerName: "Sita Kumari",
            grossWeightKg: 24.5,
            tareWeightKg: 1.5,
            netWeightKg: 23.0,
            fineLeafRatio: fineLeafRatio,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: isSynced
        )
    }

    func testSyncThrowsWhenOffline() async {
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository()
        let network = MockNetworkMonitor(isConnected: false)

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        do {
            _ = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")
            XCTFail("Expected connection failure error to be thrown")
        } catch let NetworkError.connectionFailure(message) {
            XCTAssertTrue(message.contains("offline"))
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }

    func testSyncEmptyQueue() async throws {
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [])
        let network = MockNetworkMonitor(isConnected: true)

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        XCTAssertEqual(result.processedCount, 0)
        XCTAssertEqual(result.failedCount, 0)
        XCTAssertTrue(api.recordedSyncBatches.isEmpty)
    }

    func testSyncSuccessBatch() async throws {
        let record1 = createTestRecord()
        let record2 = createTestRecord()
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [record1, record2])
        let network = MockNetworkMonitor(isConnected: true)

        api.mockSyncResponse = HarvestSyncResponseDTO(
            processedRecords: 2,
            failedRecords: 0,
            status: "success",
            syncedIds: [record1.id.uuidString, record2.id.uuidString]
        )

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        XCTAssertEqual(result.processedCount, 2)
        XCTAssertEqual(result.failedCount, 0)
        XCTAssertEqual(api.recordedSyncBatches.count, 1)
        XCTAssertEqual(harvestRepo.markedSyncedIds.count, 2)

        let unsynced = try await harvestRepo.fetchUnsyncedRecords()
        XCTAssertTrue(unsynced.isEmpty)
    }

    func testSyncPartialFailure() async throws {
        let validRecord = createTestRecord()
        let invalidRecord = createTestRecord()
        let api = MockAPIService()
        let harvestRepo = MockHarvestRepository(initialRecords: [validRecord, invalidRecord])
        let network = MockNetworkMonitor(isConnected: true)

        api.mockSyncResponse = HarvestSyncResponseDTO(
            processedRecords: 1,
            failedRecords: 1,
            status: "partial_success",
            syncedIds: [validRecord.id.uuidString]
        )

        let syncManager = OfflineSyncManager(
            apiService: api,
            harvestRepository: harvestRepo,
            networkMonitor: network
        )

        let result = try await syncManager.syncPendingRecords(supervisorId: "SUP-082")

        XCTAssertEqual(result.processedCount, 1)
        XCTAssertEqual(result.failedCount, 1)
        XCTAssertEqual(harvestRepo.markedSyncedIds.count, 1)
        XCTAssertEqual(harvestRepo.markedSyncedIds.first, validRecord.id)

        let unsynced = try await harvestRepo.fetchUnsyncedRecords()
        XCTAssertEqual(unsynced.count, 1)
        XCTAssertEqual(unsynced.first?.id, invalidRecord.id)
    }
}
#endif

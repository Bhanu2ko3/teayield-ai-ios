import Foundation
@testable import TeaYieldAI

/// Test double simulating store-and-forward batch synchronization.
final class MockSyncManager: SyncManagerProtocol {

    var isSyncing: Bool = false
    var pendingSyncCount: Int = 0
    var lastSyncTimestamp: Date?
    var lastSyncResult: SyncResult?

    var stubbedSyncResult: SyncResult?
    var shouldThrowError: Bool = false
    var errorToThrow: Error = NetworkError.connectionFailure("Simulated sync connection dropped")

    private(set) var syncPendingRecordsCallCount: Int = 0
    private(set) var refreshPendingCountCallCount: Int = 0
    private(set) var startAutoSyncCallCount: Int = 0
    private(set) var recordedSupervisorIds: [String] = []

    func syncPendingRecords(supervisorId: String) async throws -> SyncResult {
        syncPendingRecordsCallCount += 1
        recordedSupervisorIds.append(supervisorId)

        if shouldThrowError {
            throw errorToThrow
        }

        if let stubbed = stubbedSyncResult {
            self.lastSyncResult = stubbed
            self.lastSyncTimestamp = Date()
            return stubbed
        }

        let result = SyncResult(
            processedCount: pendingSyncCount,
            failedCount: 0,
            statusMessage: "Successfully synced \(pendingSyncCount) record(s).",
            timestamp: Date()
        )
        self.lastSyncResult = result
        self.lastSyncTimestamp = Date()
        self.pendingSyncCount = 0
        return result
    }

    func refreshPendingCount() async {
        refreshPendingCountCallCount += 1
    }

    func startAutoSync(supervisorId: String) {
        startAutoSyncCallCount += 1
    }
}

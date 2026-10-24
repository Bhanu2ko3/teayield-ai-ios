import Foundation

/// Outcome summary of a batch synchronization attempt.
struct SyncResult: Equatable {
    let processedCount: Int
    let failedCount: Int
    let statusMessage: String
    let timestamp: Date
}

/// Defines the contract for offline-to-online batch synchronization management.
protocol SyncManagerProtocol: AnyObject {
    var isSyncing: Bool { get }
    var pendingSyncCount: Int { get }
    var lastSyncTimestamp: Date? { get }
    var lastSyncResult: SyncResult? { get }

    /// Uploads queued offline harvest weigh-in records to the cloud backend.
    func syncPendingRecords(supervisorId: String) async throws -> SyncResult

    /// Refreshes the count of pending unsynced records from the local repository.
    func refreshPendingCount() async

    /// Initiates automated background synchronization upon network recovery.
    func startAutoSync(supervisorId: String)
}

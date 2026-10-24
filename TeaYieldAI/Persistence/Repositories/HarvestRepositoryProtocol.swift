import Foundation

/// Defines the contract for offline harvest weigh-in storage and synchronization queueing.
protocol HarvestRepositoryProtocol {
    /// Retrieves all recorded weighing logs.
    func fetchAllRecords() async throws -> [HarvestRecord]

    /// Retrieves weighing logs that have not yet been synchronized with the cloud backend.
    func fetchUnsyncedRecords() async throws -> [HarvestRecord]

    /// Returns the exact count of pending unsynced records without loading entities into memory.
    func fetchUnsyncedCount() async throws -> Int

    /// Persists a new or updated harvest weigh-in record.
    func saveRecord(_ record: HarvestRecord) async throws

    /// Updates the synchronization status of records confirmed by the server.
    func markAsSynced(recordIds: [UUID]) async throws
}

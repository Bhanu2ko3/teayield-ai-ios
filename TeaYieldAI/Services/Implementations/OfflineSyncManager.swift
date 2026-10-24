import Foundation

/// Coordinates store-and-forward synchronization between the offline Core Data repository and cloud REST API.
final class OfflineSyncManager: ObservableObject, SyncManagerProtocol {

    @Published public private(set) var isSyncing: Bool = false
    @Published public private(set) var pendingSyncCount: Int = 0
    @Published public private(set) var lastSyncTimestamp: Date?
    @Published public private(set) var lastSyncResult: SyncResult?

    private let apiService: APIServiceProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let networkMonitor: NetworkMonitor

    init(
        apiService: APIServiceProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.apiService = apiService
        self.harvestRepository = harvestRepository
        self.networkMonitor = networkMonitor
    }

    /// Listens for network restoration and triggers automatic synchronization.
    func startAutoSync(supervisorId: String) {
        networkMonitor.onConnectionRestored = { [weak self] in
            guard let self = self else { return }
            Task {
                try? await self.syncPendingRecords(supervisorId: supervisorId)
            }
        }
    }

    /// Refreshes the local pending queue count for UI badge rendering.
    @MainActor
    func refreshPendingCount() async {
        do {
            self.pendingSyncCount = try await harvestRepository.fetchUnsyncedCount()
        } catch {
            self.pendingSyncCount = 0
        }
    }

    /// Uploads queued offline harvest logs and updates synchronization status flags.
    @MainActor
    func syncPendingRecords(supervisorId: String) async throws -> SyncResult {
        // Prevent concurrent or duplicate sync operations
        guard !isSyncing else {
            return SyncResult(
                processedCount: 0,
                failedCount: 0,
                statusMessage: "Synchronization already in progress.",
                timestamp: Date()
            )
        }

        guard networkMonitor.isConnected else {
            throw NetworkError.connectionFailure("Device is offline. Records will sync when connection returns.")
        }

        isSyncing = true
        defer {
            isSyncing = false
            Task { @MainActor in
                await self.refreshPendingCount()
            }
        }

        let unsyncedRecords = try await harvestRepository.fetchUnsyncedRecords()
        guard !unsyncedRecords.isEmpty else {
            let result = SyncResult(
                processedCount: 0,
                failedCount: 0,
                statusMessage: "All weighing records are currently synchronized.",
                timestamp: Date()
            )
            self.lastSyncResult = result
            self.pendingSyncCount = 0
            return result
        }

        let uploadItems = unsyncedRecords.map { $0.toUploadItem() }
        let batch = HarvestSyncBatchDTO(
            syncTimestamp: ISO8601DateFormatter().string(from: Date()),
            supervisorId: supervisorId,
            logs: uploadItems
        )

        let response = try await apiService.syncHarvestBatch(batch)

        // Mark only records successfully acknowledged by the server (passed PostGIS ST_Contains)
        let confirmedUUIDs = response.syncedIds.compactMap { UUID(uuidString: $0) }
        if !confirmedUUIDs.isEmpty {
            try await harvestRepository.markAsSynced(recordIds: confirmedUUIDs)
        }

        let message: String
        if response.failedRecords > 0 {
            message = "Synced \(response.processedRecords) record(s). \(response.failedRecords) record(s) failed geofence boundary validation."
        } else {
            message = "Successfully synced \(response.processedRecords) record(s)."
        }

        let result = SyncResult(
            processedCount: response.processedRecords,
            failedCount: response.failedRecords,
            statusMessage: message,
            timestamp: Date()
        )

        self.lastSyncTimestamp = Date()
        self.lastSyncResult = result
        return result
    }
}

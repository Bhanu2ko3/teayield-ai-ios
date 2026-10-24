import Foundation
import SwiftUI

/// Coordinates the daily supervisor field dashboard, plucking targets, and offline sync state.
@MainActor
final class TodayTasksViewModel: ObservableObject {

    @Published var tasks: [PluckingTask] = []
    @Published var unsyncedRecordsCount: Int = 0
    @Published var isSyncing: Bool = false
    @Published var isLoading: Bool = false
    @Published var isOffline: Bool = false
    @Published var statusBannerMessage: String?
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false

    var totalTargetKg: Double {
        tasks.reduce(0.0) { $0 + $1.targetWeightKg }
    }

    var totalHarvestedKg: Double {
        tasks.reduce(0.0) { $0 + $1.harvestedWeightKg }
    }

    var overallProgressRatio: Double {
        guard totalTargetKg > 0 else { return 0.0 }
        return min(1.0, totalHarvestedKg / totalTargetKg)
    }

    var assignedPluckersTotal: Int {
        tasks.reduce(0) { $0 + $1.assignedPluckersCount }
    }

    var estateDisplayName: String {
        "Pedro Estate"
    }

    var activeArrivalFieldName: String {
        tasks.first?.fieldName ?? "Assigned Field"
    }

    private let apiService: APIServiceProtocol
    private let syncManager: SyncManagerProtocol
    private let fieldRepository: FieldRepositoryProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let tasksCacheKey = "teayield.cache.today_tasks"
    private var hasDispatchedGeofenceNotification: Bool = false

    init(
        apiService: APIServiceProtocol,
        syncManager: SyncManagerProtocol,
        fieldRepository: FieldRepositoryProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        authService: AuthServiceProtocol
    ) {
        self.apiService = apiService
        self.syncManager = syncManager
        self.fieldRepository = fieldRepository
        self.harvestRepository = harvestRepository
        self.authService = authService

        Task {
            await refreshPendingSyncCount()
        }
    }

    // MARK: - Schedule & Task Retrieval

    /// Loads daily field plucking targets from the cloud engine or falls back to local Core Data cache.
    func loadTodayTasks() async {
        isLoading = true
        errorMessage = nil

        guard let user = authService.currentUser else {
            isLoading = false
            errorMessage = "No active user session. Please log in."
            showErrorAlert = true
            return
        }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let dayIndex = max(1, min(6, (weekday == 1) ? 6 : weekday - 1))

        do {
            let response = try await apiService.fetchDailyTasks(estateId: user.estateId, dayIndex: dayIndex)
            let domainTasks = response.assignedFields.map { $0.toDomain(shiftDate: Date()) }
            self.tasks = domainTasks
            self.isOffline = false

            // Persist the official server schedule locally for offline mountain field access
            if let data = try? JSONEncoder().encode(domainTasks) {
                UserDefaults.standard.set(data, forKey: tasksCacheKey)
            }

            // Fetch and cache estate fields in background for offline persistence
            if let fieldDTOs = try? await apiService.fetchFields(estateId: user.estateId) {
                let domainFields = fieldDTOs.map { $0.toDomain() }
                try? await fieldRepository.saveFields(domainFields)
            }

            self.isLoading = false
        } catch {
            // Offline fallback: load cached official schedule
            self.isOffline = true
            loadTasksFromOfflineCache()
            self.isLoading = false
        }

        if !hasDispatchedGeofenceNotification, let active = tasks.first {
            hasDispatchedGeofenceNotification = true
            NotificationManager.shared.sendGeofenceArrivalAlert(fieldName: active.fieldName)
        }

        await refreshPendingSyncCount()
    }

    /// Triggers an immediate store-and-forward batch sync of pending weighing records.
    func triggerManualSync() async {
        guard !isSyncing else { return }
        guard let user = authService.currentUser else { return }

        isSyncing = true
        statusBannerMessage = "Uploading harvest records to estate server..."

        do {
            let result = try await syncManager.syncPendingRecords(supervisorId: user.employeeId)
            isSyncing = false
            await refreshPendingSyncCount()

            if result.failedCount > 0 {
                statusBannerMessage = "Synced \(result.processedCount), but \(result.failedCount) failed PostGIS geofence checks."
            } else if result.processedCount > 0 {
                statusBannerMessage = "Synced \(result.processedCount) record\(result.processedCount == 1 ? "" : "s") successfully."
            } else {
                statusBannerMessage = result.statusMessage
            }
        } catch {
            isSyncing = false
            statusBannerMessage = "Sync failed: \(error.localizedDescription)"
        }

        // Auto-clear banner after 4 seconds
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            if self.statusBannerMessage?.contains("Uploading") == false {
                self.statusBannerMessage = nil
            }
        }
    }

    /// Queries Core Data count of unsynced records to update badge without loading objects into memory.
    func refreshPendingSyncCount() async {
        do {
            self.unsyncedRecordsCount = try await harvestRepository.fetchUnsyncedCount()
        } catch {
            self.unsyncedRecordsCount = 0
        }
    }

    // MARK: - Private Offline Fallback

    private func loadTasksFromOfflineCache() {
        if let data = UserDefaults.standard.data(forKey: tasksCacheKey),
           let cached = try? JSONDecoder().decode([PluckingTask].self, from: data),
           !cached.isEmpty {
            self.tasks = cached
            statusBannerMessage = "Operating offline. Displaying cached schedule from estate server."
        } else {
            self.tasks = []
            statusBannerMessage = "Offline mode. Connect to estate network to sync today's schedule."
        }
    }
}

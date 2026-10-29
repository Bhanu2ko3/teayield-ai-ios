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

    @Published var estateName: String = ""

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
        if !estateName.isEmpty {
            return estateName
        }
        if let user = authService.currentUser, let estateId = user.estateId {
            return "Estate #\(estateId.uuidString.prefix(6).uppercased())"
        }
        return "Central Tea Plantation"
    }

    var activeArrivalFieldName: String {
        tasks.first?.fieldName ?? "Assigned Field"
    }

    @Published var activeGeofencedField: TeaField? = nil

    private let apiService: APIServiceProtocol
    private let syncManager: SyncManagerProtocol
    private let fieldRepository: FieldRepositoryProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let authService: AuthServiceProtocol
    let locationService: LocationServiceProtocol
    private let tasksCacheKey = "teayield.cache.today_tasks"
    private var hasDispatchedGeofenceNotification: Bool = false

    init(
        apiService: APIServiceProtocol,
        syncManager: SyncManagerProtocol,
        fieldRepository: FieldRepositoryProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        authService: AuthServiceProtocol,
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.apiService = apiService
        self.syncManager = syncManager
        self.fieldRepository = fieldRepository
        self.harvestRepository = harvestRepository
        self.authService = authService
        self.locationService = locationService

        setupGeofenceObservers()

        Task {
            await refreshPendingSyncCount()
        }
    }

    private func setupGeofenceObservers() {
        NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceEntered,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                self?.activeGeofencedField = notification.object as? TeaField
            }
        }

        NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceExited,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.activeGeofencedField = nil
            }
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

        guard let user = authService.currentUser, let estateId = user.estateId else {
            isLoading = false
            return
        }

        do {
            let response = try await apiService.fetchDailyTasks(estateId: estateId, dayIndex: dayIndex)
            let domainTasks = response.assignedFields.map { $0.toDomain(shiftDate: Date()) }
            self.tasks = domainTasks
            self.isOffline = false

            // Persist the official server schedule locally for offline mountain field access
            if let data = try? JSONEncoder().encode(domainTasks) {
                UserDefaults.standard.set(data, forKey: tasksCacheKey)
            }

            // Fetch and cache estate fields in background for offline persistence
            if let fieldDTOs = try? await apiService.fetchFields(estateId: estateId) {
                let domainFields = fieldDTOs.map { $0.toDomain() }
                try? await fieldRepository.saveFields(domainFields)
            }

            // Fetch estate enterprise profile dynamically
            if let estate = try? await apiService.fetchEstate(id: estateId) {
                self.estateName = estate.name
            }

            self.isLoading = false
        } catch {
            // Offline fallback: load cached official schedule
            self.isOffline = true
            loadTasksFromOfflineCache()
            self.isLoading = false
        }

        // Start hardware geofence monitoring for harvest-ready field boundaries
        if let cached = try? await fieldRepository.fetchCachedFields(), !cached.isEmpty {
            locationService.startMonitoringFields(cached)
        }

        await refreshPendingSyncCount()
    }

    /// Simulates arriving at a specific assigned field boundary for live demonstration during the Viva exam.
    func simulateArrival(at task: PluckingTask) {
        Task {
            let matchedField: TeaField
            if let cached = try? await fieldRepository.fetchCachedFields(),
               let existing = cached.first(where: { $0.id == task.fieldId }) {
                matchedField = existing
            } else {
                matchedField = TeaField(
                    id: task.fieldId,
                    estateId: authService.currentUser?.estateId ?? UUID(),
                    name: task.fieldName,
                    blockCode: task.blockCode,
                    acreage: 4.2,
                    currentNDVI: 0.78,
                    status: .ready,
                    centroidLatitude: task.centroidLatitude,
                    centroidLongitude: task.centroidLongitude,
                    polygonCoordinates: [],
                    lastHarvestedDate: nil
                )
            }
            locationService.simulateArrival(at: matchedField)
        }
    }

    /// Simulates exiting a field boundary to demonstrate geofence departure during the Viva exam.
    func simulateExit() {
        locationService.simulateExit()
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

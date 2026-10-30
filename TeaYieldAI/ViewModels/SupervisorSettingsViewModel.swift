import Foundation
import SwiftUI

/// Coordinates operational preferences, background sync triggers, and authenticated session state.
@MainActor
final class SupervisorSettingsViewModel: ObservableObject {

    @AppStorage("requireFaceIDOnLaunch") var requireFaceIDOnLaunch: Bool = true
    @AppStorage("offlineSyncEnabled") var offlineSyncEnabled: Bool = true
    @AppStorage("rainfallAlertsEnabled") var rainfallAlertsEnabled: Bool = true
    @AppStorage("factoryOverloadAlertsEnabled") var factoryOverloadAlertsEnabled: Bool = true
    @AppStorage("fieldRestAlertsEnabled") var fieldRestAlertsEnabled: Bool = true
    @Published var isSyncing: Bool = false
    @Published var syncStatusMessage: String?
    @Published var showingLogoutConfirmation: Bool = false
    @Published var cachedFieldsCount: Int = 0
    @Published var cachedRecordsCount: Int = 0
    @Published var notificationsAuthorized: Bool = false
    @Published var divisionAssignmentName: String = "Division Pending"
    @Published var estateDisplayName: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var selectedThemeMode: AppThemeMode = {
        let saved = UserDefaults.standard.string(forKey: "appThemeMode") ?? AppThemeMode.system.rawValue
        return AppThemeMode(rawValue: saved) ?? .system
    }()

    private static var avatarStorageURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("officer_profile_avatar.jpg")
    }

    func loadPersistedProfileImage() {
        let fileURL = Self.avatarStorageURL
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let img = UIImage(data: data) {
            self.profileImage = img
        } else {
            self.profileImage = nil
        }
    }

    func setThemeMode(_ mode: AppThemeMode) {
        selectedThemeMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "appThemeMode")
        HapticFeedback.selection()
    }

    private let authService: AuthServiceProtocol
    private let syncManager: SyncManagerProtocol
    private let fieldRepository: FieldRepositoryProtocol
    private let harvestRepository: HarvestRepositoryProtocol
    private let apiService: APIServiceProtocol?

    init(
        authService: AuthServiceProtocol,
        syncManager: SyncManagerProtocol,
        fieldRepository: FieldRepositoryProtocol,
        harvestRepository: HarvestRepositoryProtocol,
        apiService: APIServiceProtocol? = nil
    ) {
        self.authService = authService
        self.syncManager = syncManager
        self.fieldRepository = fieldRepository
        self.harvestRepository = harvestRepository
        self.apiService = apiService

        loadPersistedProfileImage()

        NotificationCenter.default.addObserver(
            forName: Notification.Name("TeaYieldProfileImageUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.loadPersistedProfileImage()
            }
        }

        Task {
            await loadCachedDetails()
            await checkNotificationStatus()
        }
    }

    // MARK: - Computed Dynamic Properties

    var officerName: String {
        guard let name = authService.currentUser?.fullName, !name.isEmpty else {
            return "Unassigned Officer"
        }
        return name
    }

    var officerRole: String {
        authService.currentUser?.role.title ?? "Field Officer"
    }

    var officerEmployeeId: String {
        if let id = authService.currentUser?.employeeId, !id.isEmpty {
            return id
        }
        if let user = authService.currentUser {
            return "ID-\(user.id.uuidString.prefix(6).uppercased())"
        }
        return "Not Assigned"
    }

    var officerEmail: String {
        guard let email = authService.currentUser?.email, !email.isEmpty else {
            return "Not Provided"
        }
        return email
    }

    var isAccountVerified: Bool {
        authService.currentUser != nil
    }

    var estateName: String {
        if !estateDisplayName.isEmpty {
            return estateDisplayName
        }
        if let user = authService.currentUser, let estateId = user.estateId {
            return "Estate #\(estateId.uuidString.prefix(6).uppercased())"
        }
        return "Estate Not Assigned"
    }

    var divisionAssignment: String {
        divisionAssignmentName
    }

    var avatarInitials: String {
        guard let name = authService.currentUser?.fullName, !name.isEmpty else {
            return "OF"
        }
        let parts = name.split(separator: " ")
        if let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var appVersionDisplay: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.4.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "082"
        return "v\(version) (Build \(build))"
    }

    var environmentName: String {
        AppConfiguration.environmentName
    }

    // MARK: - Actions

    func loadCachedDetails() async {
        if let user = authService.currentUser, let estateId = user.estateId, let api = apiService {
            if let estate = try? await api.fetchEstate(id: estateId) {
                self.estateDisplayName = estate.name
            }
        }

        if let fields = try? await fieldRepository.fetchAllFields() {
            self.cachedFieldsCount = fields.count
            if let first = fields.first {
                self.divisionAssignmentName = "\(first.name) (\(first.blockCode))"
            } else {
                self.divisionAssignmentName = "Division Pending"
            }
        }
        if let records = try? await harvestRepository.fetchAllRecords() {
            self.cachedRecordsCount = records.count
        }
    }

    func checkNotificationStatus() async {
        await NotificationManager.shared.checkAuthorizationStatus()
        self.notificationsAuthorized = NotificationManager.shared.isAuthorized
    }

    func requestNotificationPermissionIfNeeded() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            self.notificationsAuthorized = granted
        }
    }

    func triggerManualSync() {
        guard let user = authService.currentUser else { return }
        isSyncing = true
        syncStatusMessage = nil

        Task {
            do {
                let result = try await syncManager.syncPendingRecords(supervisorId: user.employeeId)
                await MainActor.run {
                    self.isSyncing = false
                    self.syncStatusMessage = result.statusMessage
                }
                await self.loadCachedDetails()
            } catch {
                await MainActor.run {
                    self.isSyncing = false
                    self.syncStatusMessage = "Sync failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func logout() {
        authService.logout()
    }
}

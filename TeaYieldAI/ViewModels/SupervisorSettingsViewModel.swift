import Foundation
import SwiftUI

/// Coordinates operational preferences, background sync triggers, and authenticated session state.
@MainActor
final class SupervisorSettingsViewModel: ObservableObject {

    @Published var offlineSyncEnabled: Bool = true
    @Published var requireFaceIDOnLaunch: Bool = true
    @Published var rainfallAlertsEnabled: Bool = true
    @Published var factoryOverloadAlertsEnabled: Bool = true
    @Published var fieldRestAlertsEnabled: Bool = true
    @Published var isSyncing: Bool = false
    @Published var syncStatusMessage: String?
    @Published var showingLogoutConfirmation: Bool = false
    @Published var cachedFieldsCount: Int = 0
    @Published var divisionAssignmentName: String = "Division Pending"

    private let authService: AuthServiceProtocol
    private let syncManager: SyncManagerProtocol
    private let fieldRepository: FieldRepositoryProtocol

    init(
        authService: AuthServiceProtocol,
        syncManager: SyncManagerProtocol,
        fieldRepository: FieldRepositoryProtocol
    ) {
        self.authService = authService
        self.syncManager = syncManager
        self.fieldRepository = fieldRepository

        Task {
            await loadCachedDetails()
        }
    }

    // MARK: - Computed Dynamic Properties

    var officerName: String {
        guard let name = authService.currentUser?.fullName, !name.isEmpty else {
            return "Officer Name"
        }
        return name
    }

    var officerRole: String {
        authService.currentUser?.role.title ?? "Field Officer"
    }

    var officerEmployeeId: String {
        guard let id = authService.currentUser?.employeeId, !id.isEmpty else {
            return "EMP-001"
        }
        return id
    }

    var officerEmail: String {
        guard let email = authService.currentUser?.email, !email.isEmpty else {
            return "officer@estate.lk"
        }
        return email
    }

    var isAccountVerified: Bool {
        authService.currentUser != nil
    }

    var estateName: String {
        if let user = authService.currentUser {
            return "Estate ID: \(user.estateId.uuidString.prefix(8))..."
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
        if let fields = try? await fieldRepository.fetchAllFields() {
            self.cachedFieldsCount = fields.count
            if let first = fields.first {
                self.divisionAssignmentName = "\(first.name) (\(first.blockCode))"
            } else {
                self.divisionAssignmentName = "Division Pending"
            }
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

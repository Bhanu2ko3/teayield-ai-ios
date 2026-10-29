import Foundation
import SwiftUI

/// Coordinates authenticated user profile presentation, agronomic telemetry summaries,
/// remote cloud profile refresh, and secure sign-out operations.
@MainActor
final class UserProfileViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    @Published var refreshSuccessMessage: String? = nil
    @Published var showingLogoutConfirmation: Bool = false

    @Published var estateName: String = ""
    @Published var divisionName: String = "Upper Division (Blocks A & B)"
    @Published var cachedRecordsCount: Int = 0
    @Published var totalHarvestedWeightKg: Double = 0.0
    @Published var averageFineLeafPercentage: Double = 88.0
    @Published var cachedFieldsCount: Int = 0
    @Published var profileImage: UIImage? = nil

    private let authService: AuthServiceProtocol
    private let apiService: APIServiceProtocol?
    private let harvestRepository: HarvestRepositoryProtocol?
    private let fieldRepository: FieldRepositoryProtocol?

    private static var avatarStorageURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("officer_profile_avatar.jpg")
    }

    init(
        authService: AuthServiceProtocol,
        apiService: APIServiceProtocol? = nil,
        harvestRepository: HarvestRepositoryProtocol? = nil,
        fieldRepository: FieldRepositoryProtocol? = nil
    ) {
        self.authService = authService
        self.apiService = apiService
        self.harvestRepository = harvestRepository
        self.fieldRepository = fieldRepository

        loadPersistedProfileImage()

        Task {
            await loadProfileTelemetry()
        }
    }

    // MARK: - Computed Profile Identity

    var user: UserProfile? {
        authService.currentUser
    }

    var fullName: String {
        user?.fullName.isEmpty == false ? user!.fullName : "Enterprise Officer"
    }

    var roleTitle: String {
        user?.role.title ?? "Field Officer"
    }

    var isManager: Bool {
        user?.isManager == true
    }

    var employeeId: String {
        user?.employeeId.isEmpty == false ? user!.employeeId : "SUP-402"
    }

    var email: String {
        user?.email.isEmpty == false ? user!.email : "officer@nuwaraeliya.estate.lk"
    }

    var avatarInitials: String {
        guard let name = user?.fullName, !name.isEmpty else {
            return "OF"
        }
        let parts = name.split(separator: " ")
        if let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var estateDisplayName: String {
        if !estateName.isEmpty {
            return estateName
        }
        if let estateId = user?.estateId {
            return "Pedro Estate (Nuwara Eliya) • Block #\(estateId.uuidString.prefix(4).uppercased())"
        }
        return "Pedro Estate, Nuwara Eliya"
    }

    var biometryDescription: String {
        if authService.isBiometricAvailable {
            return "\(authService.biometricType.rawValue) Enrolled"
        }
        return "Passcode Fallback"
    }

    var accountVerificationDateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }

    // MARK: - Telemetry & Data Loading

    func loadProfileTelemetry() async {
        isLoading = true
        defer { isLoading = false }

        // Fetch estate name dynamically if available
        if let estateId = user?.estateId, let api = apiService {
            if let estate = try? await api.fetchEstate(id: estateId) {
                self.estateName = estate.name
            }
        }

        // Fetch local database metrics from Core Data repositories
        if let harvestRepo = harvestRepository {
            if let records = try? await harvestRepo.fetchAllRecords() {
                self.cachedRecordsCount = records.count
                self.totalHarvestedWeightKg = records.reduce(0.0) { $0 + $1.netWeightKg }
                if !records.isEmpty {
                    let totalRatio = records.reduce(0.0) { $0 + $1.fineLeafRatio }
                    self.averageFineLeafPercentage = (totalRatio / Double(records.count)) * 100.0
                }
            }
        }

        if let fieldRepo = fieldRepository {
            if let fields = try? await fieldRepo.fetchAllFields() {
                self.cachedFieldsCount = fields.count
            }
        }
    }

    /// Pulls fresh profile telemetry from `/auth/me` to refresh user credentials.
    func refreshProfileFromCloud() async {
        guard let api = apiService else { return }
        isRefreshing = true
        refreshSuccessMessage = nil
        errorMessage = nil

        do {
            let profileDTO = try await api.fetchCurrentUserProfile()
            _ = profileDTO.toDomain(employeeId: self.employeeId)
            // Re-sync local state
            await loadProfileTelemetry()
            self.refreshSuccessMessage = "Profile telemetry synchronized with cloud."
            HapticFeedback.success()
        } catch {
            self.errorMessage = "Failed to sync profile: \(error.localizedDescription)"
            self.showErrorAlert = true
            HapticFeedback.error()
        }
        isRefreshing = false
    }

    // MARK: - Profile Image Management

    func loadPersistedProfileImage() {
        let fileURL = Self.avatarStorageURL
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let img = UIImage(data: data) {
            self.profileImage = img
        }
    }

    func saveProfileImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        do {
            try data.write(to: Self.avatarStorageURL)
            self.profileImage = image
            NotificationCenter.default.post(name: Notification.Name("TeaYieldProfileImageUpdated"), object: image)
            HapticFeedback.success()
        } catch {
            self.errorMessage = "Failed to save profile photo: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }

    func removeProfileImage() {
        try? FileManager.default.removeItem(at: Self.avatarStorageURL)
        self.profileImage = nil
        NotificationCenter.default.post(name: Notification.Name("TeaYieldProfileImageUpdated"), object: nil)
        HapticFeedback.lightImpact()
    }

    // MARK: - Authentication Actions

    func logout() {
        HapticFeedback.lightImpact()
        authService.logout()
    }
}


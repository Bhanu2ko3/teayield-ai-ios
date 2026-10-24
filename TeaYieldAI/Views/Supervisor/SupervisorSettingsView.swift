import SwiftUI

/// Operational settings, offline database diagnostics, and supervisor profile dashboard.
/// Conforms to Figma Screen 08 (Settings) and Screen 09 (Field Officer Profile).
struct SupervisorSettingsView: View {

    private let container: AppContainerProtocol
    @ObservedObject private var authService: AuthService
    @State private var offlineSyncEnabled: Bool = true
    @State private var requireFaceIDOnLaunch: Bool = true
    @State private var rainfallAlertsEnabled: Bool = true
    @State private var factoryOverloadAlertsEnabled: Bool = true
    @State private var fieldRestAlertsEnabled: Bool = true
    @State private var isSyncing: Bool = false
    @State private var syncStatusMessage: String?
    @State private var showingLogoutConfirmation: Bool = false

    init(container: AppContainerProtocol) {
        self.container = container
        self.authService = container.authService as! AuthService
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        officerProfileCard
                        dataAndStorageSection
                        securitySection
                        notificationsSection
                        appInfoSection
                        accountActionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings & Profile")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    authService.logout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your cached records will remain safe in Core Data offline storage.")
            }
        }
    }

    // MARK: - Subviews

    private var officerProfileCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 58, height: 58)

                    Text(avatarInitials)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(authService.currentUser?.fullName ?? "Kusal Bandara")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Senior Field Superintendent • ID: \(authService.currentUser?.employeeId ?? "SUP-402")")
                        .font(.appCaption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Text(authService.currentUser?.email ?? "bhanuka@pedroestates.lk")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)

                        Text("VERIFIED")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(AppTheme.emerald.opacity(0.15))
                            .foregroundColor(AppTheme.emerald)
                            .cornerRadius(4)
                    }
                }

                Spacer()
            }

            Divider()
                .padding(.vertical, 2)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Assigned Estate")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Pedro Estate, Nuwara Eliya")
                        .font(.appCallout)
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Division Access")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Upper Div (Blocks 01-14)")
                        .font(.appCallout)
                        .foregroundColor(AppTheme.emerald)
                }
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var dataAndStorageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "DATA & OFFLINE STORAGE (CORE DATA)")

            VStack(spacing: 0) {
                Toggle(isOn: $offlineSyncEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "externaldrive.fill")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Offline Core Data Sync")
                            .font(.appBody)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "cylinder.split.1x2.fill")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Local Database Storage")
                                .font(.appBody)
                            Text("SQLite Relational Persistence")
                                .font(.appCaption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Text("Active")
                        .font(.appBadge)
                        .foregroundColor(AppTheme.emerald)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.emerald.opacity(0.12))
                        .cornerRadius(6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                Button {
                    triggerManualSync()
                } label: {
                    HStack(spacing: 8) {
                        if isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.emerald))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14, weight: .bold))
                        }

                        Text(isSyncing ? "Syncing..." : "Manual Sync with Supabase")
                            .font(.appHeadline)
                    }
                    .foregroundColor(AppTheme.emerald)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppTheme.emerald.opacity(0.08))
                    .cornerRadius(AppTheme.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                            .stroke(AppTheme.emerald.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(14)
                .disabled(isSyncing)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)

            if let message = syncStatusMessage {
                Text(message)
                    .font(.appCaption)
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 8)
            }
        }
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "SECURITY & AUTHENTICATION")

            VStack(spacing: 0) {
                Toggle(isOn: $requireFaceIDOnLaunch) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Require Face ID on Launch")
                            .font(.appBody)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Biometric Vault Tier")
                            .font(.appBody)
                    }

                    Spacer()

                    Text("TrueDepth Face ID")
                        .font(.appCallout)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "SYSTEM NOTIFICATIONS (USERNOTIFICATIONS)")

            VStack(spacing: 0) {
                Toggle(isOn: $rainfallAlertsEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "cloud.rain.fill")
                            .foregroundColor(.blue)
                            .frame(width: 22)
                        Text("Rainfall & Hazard Alerts")
                            .font(.appBody)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                Toggle(isOn: $factoryOverloadAlertsEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppTheme.amber)
                            .frame(width: 22)
                        Text("Factory Overload Warnings")
                            .font(.appBody)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                Toggle(isOn: $fieldRestAlertsEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Field Rest Period Notifications")
                            .font(.appBody)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: "APP INFO & SUPPORT")

            VStack(spacing: 0) {
                HStack {
                    Text("App Version")
                        .font(.appBody)
                    Spacer()
                    Text("v2.4.0 (Build 082)")
                        .font(.appCallout)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.horizontal, 16)

                HStack {
                    Text("Author Index")
                        .font(.appBody)
                    Spacer()
                    Text("Index 25.1 / 082 (Bhanuka Bandara)")
                        .font(.appCallout)
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    private var accountActionsSection: some View {
        Button {
            showingLogoutConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out of Enterprise Account")
                    .fontWeight(.bold)
            }
            .font(.appHeadline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.red.opacity(0.08))
            .cornerRadius(AppTheme.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
    }

    private var avatarInitials: String {
        let name = authService.currentUser?.fullName ?? "Kusal Bandara"
        let parts = name.split(separator: " ")
        if let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)"
        }
        return "KB"
    }

    private func triggerManualSync() {
        guard let user = authService.currentUser else { return }
        isSyncing = true
        syncStatusMessage = nil

        Task {
            do {
                let result = try await container.syncManager.syncPendingRecords(supervisorId: user.employeeId)
                await MainActor.run {
                    self.isSyncing = false
                    self.syncStatusMessage = result.statusMessage
                }
            } catch {
                await MainActor.run {
                    self.isSyncing = false
                    self.syncStatusMessage = "Sync failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

import SwiftUI

/// Settings section managing local SQLite persistence and store-and-forward cloud synchronization.
struct DataStorageSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA & OFFLINE STORAGE (CORE DATA)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.offlineSyncEnabled) {
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
                    viewModel.triggerManualSync()
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.emerald))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14, weight: .bold))
                        }

                        Text(viewModel.isSyncing ? "Syncing..." : "Manual Sync with Supabase")
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
                .disabled(viewModel.isSyncing)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)

            if let message = viewModel.syncStatusMessage {
                Text(message)
                    .font(.appCaption)
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 8)
            }
        }
    }
}

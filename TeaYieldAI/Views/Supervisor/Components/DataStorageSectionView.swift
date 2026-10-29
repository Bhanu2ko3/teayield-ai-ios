import SwiftUI

/// Settings section managing local SQLite persistence and store-and-forward cloud synchronization.
struct DataStorageSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel
    let harvestRepository: HarvestRepositoryProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA & OFFLINE STORAGE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.offlineSyncEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "externaldrive.fill")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Offline Storage Sync")
                            .font(.system(size: 14, weight: .medium))
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
                            Text("Cached Offline Records")
                                .font(.system(size: 14, weight: .medium))
                            Text("Encrypted local storage")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(viewModel.cachedFieldsCount) Blocks")
                            .font(.appBadge)
                            .foregroundColor(AppTheme.emerald)

                        Text("\(viewModel.cachedRecordsCount) Logs")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.emerald.opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                NavigationLink {
                    HarvestHistoryView(harvestRepository: harvestRepository)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Weighing Log History")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Inspect locally cached harvest logs")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityLabel("Weighing Log History")
                .accessibilityHint("Opens screen showing all locally recorded green leaf weigh-ins")
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.leading, 50)

                TeaYieldButton(
                    title: viewModel.isSyncing ? "Syncing..." : "Synchronize Database",
                    icon: "arrow.triangle.2.circlepath",
                    style: .tonal,
                    isLoading: viewModel.isSyncing
                ) {
                    viewModel.triggerManualSync()
                }
                .accessibilityLabel("Synchronize Database")
                .accessibilityHint("Uploads queued offline weighing logs to estate server")
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

// MARK: - Previews

struct DataStorageSectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataStorageSectionView(
            viewModel: SupervisorSettingsViewModel(
                authService: AppContainer.shared.authService,
                syncManager: AppContainer.shared.syncManager,
                fieldRepository: AppContainer.shared.fieldRepository,
                harvestRepository: AppContainer.shared.harvestRepository,
                apiService: AppContainer.shared.apiService
            ),
            harvestRepository: AppContainer.shared.harvestRepository
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


import SwiftUI

/// Settings section configuring operational push notifications and hazard warnings.
struct NotificationSettingsSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SYSTEM NOTIFICATIONS (USERNOTIFICATIONS)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                Text(viewModel.notificationsAuthorized ? "AUTHORIZED" : "PERMISSION REQUIRED")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((viewModel.notificationsAuthorized ? AppTheme.emerald : AppTheme.amber).opacity(0.15))
                    .foregroundColor(viewModel.notificationsAuthorized ? AppTheme.emerald : AppTheme.amber)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.rainfallAlertsEnabled) {
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
                .onChange(of: viewModel.rainfallAlertsEnabled) { enabled in
                    if enabled { viewModel.requestNotificationPermissionIfNeeded() }
                }

                Divider().padding(.leading, 50)

                Toggle(isOn: $viewModel.factoryOverloadAlertsEnabled) {
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
                .onChange(of: viewModel.factoryOverloadAlertsEnabled) { enabled in
                    if enabled { viewModel.requestNotificationPermissionIfNeeded() }
                }

                Divider().padding(.leading, 50)

                Toggle(isOn: $viewModel.fieldRestAlertsEnabled) {
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
                .onChange(of: viewModel.fieldRestAlertsEnabled) { enabled in
                    if enabled { viewModel.requestNotificationPermissionIfNeeded() }
                }
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)

            if !viewModel.notificationsAuthorized {
                Button {
                    viewModel.requestNotificationPermissionIfNeeded()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 11))
                        Text("Tap to Grant System Notification Permission")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.amber)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

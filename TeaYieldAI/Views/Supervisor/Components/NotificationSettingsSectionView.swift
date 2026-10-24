import SwiftUI

/// Settings section configuring operational push notifications and hazard warnings.
struct NotificationSettingsSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SYSTEM NOTIFICATIONS (USERNOTIFICATIONS)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
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
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }
}

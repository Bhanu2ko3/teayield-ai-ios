import SwiftUI

/// Settings section displaying client application version and runtime environment info.
struct AppInfoSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APP INFO & SUPPORT")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("App Version")
                        .font(.appBody)
                    Spacer()
                    Text(viewModel.appVersionDisplay)
                        .font(.appCallout)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.horizontal, 16)

                HStack {
                    Text("Environment")
                        .font(.appBody)
                    Spacer()
                    Text(viewModel.environmentName)
                        .font(.appCallout)
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }
}

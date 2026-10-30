import SwiftUI

/// Settings section displaying client application version and runtime environment info.
struct AppInfoSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("APPLICATION INFO")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                HStack {
                    Text("App Version")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Text(viewModel.appVersionDisplay)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.horizontal, 16)

                HStack {
                    Text("API Gateway")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Text(viewModel.environmentName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().padding(.horizontal, 16)

                HStack {
                    Text("On-Device ML Engine")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Text("Apple Neural Engine CoreML")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }
}

// MARK: - Previews

struct AppInfoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoSectionView(
            viewModel: SupervisorSettingsViewModel(
                authService: AppContainer.shared.authService,
                syncManager: AppContainer.shared.syncManager,
                fieldRepository: AppContainer.shared.fieldRepository,
                harvestRepository: AppContainer.shared.harvestRepository,
                apiService: AppContainer.shared.apiService
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


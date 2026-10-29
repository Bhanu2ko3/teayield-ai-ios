import SwiftUI

/// Settings section managing biometric hardware access and Secure Enclave authentication.
struct SecuritySettingsSectionView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SECURITY & AUTHENTICATION")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                Toggle(isOn: $viewModel.requireFaceIDOnLaunch) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 22)
                        Text("Require Face ID on Launch")
                            .font(.appBody)
                    }
                }
                .accessibilityLabel("Require Face ID on Launch")
                .accessibilityHint("Toggles biometric authentication requirement when opening the application")
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
}

// MARK: - Previews

struct SecuritySettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsSectionView(
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


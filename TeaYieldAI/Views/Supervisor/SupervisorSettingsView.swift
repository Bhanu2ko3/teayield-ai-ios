import SwiftUI

/// Operational settings, offline database diagnostics, and supervisor profile dashboard.
/// Composes modular sub-components for profile, storage, security, and notification settings.
struct SupervisorSettingsView: View {

    private let container: AppContainerProtocol
    @StateObject private var viewModel: SupervisorSettingsViewModel
    @State private var showingFullProfileSheet: Bool = false

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: SupervisorSettingsViewModel(
                authService: container.authService,
                syncManager: container.syncManager,
                fieldRepository: container.fieldRepository,
                harvestRepository: container.harvestRepository,
                apiService: container.apiService
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        OfficerProfileCardView(
                            viewModel: viewModel,
                            onViewFullProfileTap: {
                                showingFullProfileSheet = true
                            }
                        )
                        AppearanceSettingsSectionView(viewModel: viewModel)
                        DataStorageSectionView(
                            viewModel: viewModel,
                            harvestRepository: container.harvestRepository
                        )
                        SecuritySettingsSectionView(viewModel: viewModel)
                        NotificationSettingsSectionView(viewModel: viewModel)
                        AppInfoSectionView(viewModel: viewModel)
                        logoutButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings & Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFullProfileSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.emerald)
                    }
                    .accessibilityLabel("View full officer profile")
                }
            }
            .sheet(isPresented: $showingFullProfileSheet) {
                UserProfileView(
                    authService: container.authService,
                    apiService: container.apiService,
                    harvestRepository: container.harvestRepository,
                    fieldRepository: container.fieldRepository
                )
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $viewModel.showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your cached records will remain safe in Core Data offline storage.")
            }
        }
    }

    // MARK: - Subviews

    private var logoutButton: some View {
        TeaYieldButton(
            title: "Log Out of Enterprise Account",
            icon: "rectangle.portrait.and.arrow.right",
            style: .destructive,
            action: {
                viewModel.showingLogoutConfirmation = true
            }
        )
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

// MARK: - Previews

struct SupervisorSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SupervisorSettingsView(container: AppContainer.shared)
    }
}


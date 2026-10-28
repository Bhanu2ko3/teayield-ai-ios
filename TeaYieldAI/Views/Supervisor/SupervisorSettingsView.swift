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
        Button {
            viewModel.showingLogoutConfirmation = true
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
        .accessibilityLabel("Log Out of Enterprise Account")
        .accessibilityHint("Prompts confirmation to sign out of supervisor account")
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

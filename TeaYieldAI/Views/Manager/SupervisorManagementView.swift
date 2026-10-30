import SwiftUI

/// Dedicated field supervisor management and roster overview screen for estate managers.
/// Lists active supervisors, corporate emails, employee codes, and provides an invite button.
struct SupervisorManagementView: View {

    @StateObject private var viewModel: SupervisorManagementViewModel
    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: SupervisorManagementViewModel(
                apiService: container.apiService,
                authService: container.authService
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Header Banner
                        supervisorHeroCard

                        // Search Bar
                        TeaYieldSearchBar(
                            text: $viewModel.searchText,
                            placeholder: "Search by supervisor name or employee ID..."
                        )

                        // Supervisor Roster List
                        if viewModel.isLoading && viewModel.supervisors.isEmpty {
                            ProgressView("Loading supervisors...")
                                .padding(.top, 40)
                        } else if viewModel.filteredSupervisors.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredSupervisors) { supervisor in
                                    supervisorCard(supervisor)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .refreshable {
                    await viewModel.loadSupervisors()
                }
            }
            .navigationTitle("Field Supervisors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isShowingInviteSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Invite")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.emerald)
                    }
                    .accessibilityLabel("Invite subordinate field supervisor")
                }
            }
            .sheet(isPresented: $viewModel.isShowingInviteSheet) {
                InviteSupervisorSheetView(
                    apiService: container.apiService,
                    showsDismissButton: true
                )
            }
            .confirmationDialog(
                "Revoke Field Supervisor Delegation?",
                isPresented: $viewModel.isShowingRevokeConfirmation,
                titleVisibility: .visible,
                presenting: viewModel.supervisorToDelete
            ) { supervisor in
                Button("Revoke \(supervisor.fullName)", role: .destructive) {
                    Task {
                        await viewModel.revokeSupervisor(supervisor)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { supervisor in
                Text("Are you sure you want to revoke field access credentials for \(supervisor.fullName) (\(supervisor.employeeId))?")
            }
            .task {
                await viewModel.loadSupervisors()
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var supervisorHeroCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.14))
                    .frame(width: 48, height: 48)

                Image(systemName: "person.badge.shield.checkmark.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Operational Field Staff")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Supervisors coordinate daily plucking tasks, edge AI leaf scans, and field weigh-ins.")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search supervisor by name or email...", text: $viewModel.searchText)
                .font(.appBody)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
    }

    private func supervisorCard(_ supervisor: UserProfile) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(supervisor.fullName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(supervisor.employeeId)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.emerald.opacity(0.12))
                        .foregroundColor(AppTheme.emerald)
                        .cornerRadius(AppTheme.radiusSmall)

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(supervisor.email)
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 6)

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 6) {
                    Text("SUPERVISOR")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.emerald.opacity(0.12))
                        .cornerRadius(AppTheme.radiusSmall)

                    Menu {
                        Button {
                            // Resend password rotation email notification
                            HapticFeedback.success()
                        } label: {
                            Label("Resend Invite", systemImage: "paperplane")
                        }

                        Divider()

                        Button(role: .destructive) {
                            viewModel.supervisorToDelete = supervisor
                            viewModel.isShowingRevokeConfirmation = true
                        } label: {
                            Label("Revoke Delegation", systemImage: "person.crop.circle.badge.xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                            .padding(2)
                    }
                }

                if supervisor.mustChangePassword {
                    Text("PENDING ROTATION")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(AppTheme.amber)
                }
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 24)

            Text("No Supervisors Found")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("Delegate a field supervisor with a manager-issued temporary password to oversee plucking gangs.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Button {
                viewModel.isShowingInviteSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane.fill")
                    Text("Invite Supervisor Now")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.emerald)
                .cornerRadius(AppTheme.radiusMedium)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

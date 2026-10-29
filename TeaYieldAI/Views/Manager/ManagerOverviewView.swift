import SwiftUI

/// Executive oversight dashboard for estate managers and agronomists coordinating macro yield and factory intake.
struct ManagerOverviewView: View {

    @StateObject private var viewModel: ManagerOverviewViewModel
    private let container: AppContainerProtocol
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue
    @State private var showingFullProfileSheet: Bool = false
    @State private var isShowingInviteSupervisorSheet: Bool = false

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: ManagerOverviewViewModel(
                fieldRepository: container.fieldRepository,
                harvestRepository: container.harvestRepository,
                authService: container.authService,
                apiService: container.apiService
            )
        )
    }

    private var currentThemeMode: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        managerProfileHeader
                        AppearanceSettingsSectionView()
                        FactoryIntakeCardView(
                            currentIntakeKg: viewModel.totalHarvestTodayKg,
                            capacityCapKg: viewModel.factoryIntakeCapKg,
                            utilizationRatio: viewModel.factoryUtilizationRatio,
                            remainingCapacityKg: viewModel.remainingCapacityKg
                        )

                        NavigationLink {
                            ManagerAnalyticsDashboardView(viewModel: viewModel)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.emerald)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Harvest & Yield Analytics")
                                        .font(.appHeadline)
                                        .foregroundColor(.primary)
                                    Text("Interactive 7-Day predictions & NDVI trends")
                                        .font(.appCaption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
                        }
                        .accessibilityLabel("Open harvest and yield analytics with interactive Swift Charts")

                        estateMacroKpiGrid
                        ndviDistributionSection
                        estateDivisionsSection
                        teamDelegationSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.loadEstateTelemetry()
                }
            }
            .navigationTitle("Executive Overview")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingInviteSupervisorSheet) {
                InviteSupervisorSheetView(apiService: container.apiService)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    themeMenuButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        viewModel.showingLogoutConfirmation = true
                    }
                    .foregroundColor(.red)
                }
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
                Text("Your manager session will end and return to the login screen.")
            }
            .alert("Estate Telemetry Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected telemetry error occurred.")
            }
            .task {
                await viewModel.loadEstateTelemetry()
            }
            .sheet(isPresented: $showingFullProfileSheet) {
                UserProfileView(
                    authService: container.authService,
                    apiService: container.apiService,
                    harvestRepository: container.harvestRepository,
                    fieldRepository: container.fieldRepository
                )
            }
            .applyAppTheme()
        }
    }

    private var themeMenuButton: some View {
        Menu {
            ForEach(AppThemeMode.allCases) { mode in
                Button {
                    HapticFeedback.selection()
                    appThemeMode = mode.rawValue
                } label: {
                    Label(mode.title, systemImage: mode.iconName)
                }
            }
        } label: {
            Image(systemName: currentThemeMode.iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.emerald)
        }
        .accessibilityLabel("Appearance Theme Switcher")
    }

    // MARK: - Subviews

    private var managerProfileHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 52, height: 52)

                    Image(systemName: "briefcase.fill")
                        .foregroundColor(AppTheme.emerald)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.managerName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Estate General Manager • Agronomy Director")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            HStack {
                HStack(spacing: 6) {
                    Text("EMPLOYEE ID")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(viewModel.managerEmployeeId)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.emerald)
                    Text(viewModel.estateDisplayName)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Button {
                showingFullProfileSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 13))
                    Text("View Full Manager Profile")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(AppTheme.emerald)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.emerald.opacity(0.08))
                .cornerRadius(AppTheme.radiusSmall)
            }
            .accessibilityLabel("View full manager profile")
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var estateMacroKpiGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                kpiCard(
                    title: "Total Acreage",
                    value: String(format: "%.1f Ac", viewModel.totalAcreage),
                    icon: "map.fill",
                    tint: .blue
                )

                kpiCard(
                    title: "Active Blocks",
                    value: "\(viewModel.fields.count)",
                    icon: "square.grid.2x2.fill",
                    tint: AppTheme.emerald
                )
            }

            HStack(spacing: 10) {
                kpiCard(
                    title: "Daily Intake",
                    value: String(format: "%.0f kg", viewModel.totalHarvestTodayKg),
                    icon: "scalemass.fill",
                    tint: .purple
                )

                kpiCard(
                    title: "Fine Leaf Avg",
                    value: String(format: "%.1f%%", viewModel.averageFineLeafPercentage),
                    icon: "checkmark.seal.fill",
                    tint: AppTheme.emerald
                )
            }
        }
    }

    private var ndviDistributionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                title: "CANOPY HEALTH DISTRIBUTION (SENTINEL-2 NDVI)",
                subtitle: "Chlorophyll reflectance spectrum across active fields",
                icon: "chart.pie.fill"
            )

            HStack(spacing: 10) {
                statusPill(title: "Ready", count: viewModel.readyFieldsCount, color: AppTheme.emerald)
                statusPill(title: "Growing", count: viewModel.growingFieldsCount, color: AppTheme.amber)
                statusPill(title: "Resting", count: viewModel.restingFieldsCount, color: AppTheme.crimson)
            }
        }
    }

    private var estateDivisionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                title: "ESTATE DIVISIONS & NDVI STATUS",
                subtitle: "Sentinel-2 vegetative canopy health across plantation blocks",
                icon: "leaf.fill",
                badge: "\(viewModel.fields.count) DIVISIONS",
                badgeColor: AppTheme.emerald
            )

            if viewModel.fields.isEmpty && !viewModel.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.6))

                    Text("No Estate Divisions Found")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Field boundaries and vegetative health logs will populate after synchronizing with the database.")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.fields) { field in
                        ManagerFieldRowView(field: field)
                    }
                }
            }
        }
    }

    private func kpiCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .font(.system(size: 14))
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private func statusPill(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(title)
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private var teamDelegationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 16))

                Text("Team & Staff Delegation")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    isShowingInviteSupervisorSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 12))
                        Text("Invite")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.emerald)
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel("Invite subordinate field supervisor")
            }

            Text("Provision field supervisors with manager-issued temporary passwords to coordinate weighing and leaf quality scans.")
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

// MARK: - Previews

struct ManagerOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerOverviewView(container: AppContainer.shared)
    }
}



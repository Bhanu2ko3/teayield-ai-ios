import SwiftUI

/// Executive oversight dashboard for estate managers and agronomists coordinating macro yield and factory intake.
struct ManagerOverviewView: View {

    @AppStorage("requireFaceIDOnLaunch") private var requireFaceIDOnLaunch: Bool = true
    @StateObject private var viewModel: ManagerOverviewViewModel
    private let container: AppContainerProtocol
    @State private var showingFullProfileSheet: Bool = false
    @State private var isShowingEditEstateSheet: Bool = false
    @State private var isShowingAddFieldSheet: Bool = false
    @State private var editingField: TeaField? = nil
    @State private var fieldToDelete: TeaField? = nil
    @State private var isShowingDeleteFieldConfirmation: Bool = false

    init(container: AppContainerProtocol, viewModel: ManagerOverviewViewModel? = nil) {
        self.container = container
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(
                wrappedValue: ManagerOverviewViewModel(
                    fieldRepository: container.fieldRepository,
                    harvestRepository: container.harvestRepository,
                    authService: container.authService,
                    apiService: container.apiService
                )
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        managerProfileHeader
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
                                    Text("7-Day yield forecast & Sentinel-2 NDVI trends")
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
            .sheet(isPresented: $isShowingEditEstateSheet) {
                if let estateId = container.authService.currentUser?.estateId {
                    EditEstateSheetView(
                        apiService: container.apiService,
                        estateId: estateId,
                        currentName: viewModel.estateName,
                        currentAcres: viewModel.totalAcreage,
                        currentCapacityKg: viewModel.factoryIntakeCapKg,
                        onUpdated: {
                            Task {
                                await viewModel.loadEstateTelemetry()
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $isShowingAddFieldSheet) {
                if let estateId = container.authService.currentUser?.estateId {
                    AddFieldDivisionSheetView(
                        apiService: container.apiService,
                        estateId: estateId,
                        onCreated: {
                            Task {
                                await viewModel.loadEstateTelemetry()
                            }
                        }
                    )
                }
            }
            .sheet(item: $editingField) { field in
                EditFieldDivisionSheetView(
                    field: field,
                    onUpdated: { updated in
                        Task {
                            await viewModel.updateFieldLocally(updated)
                        }
                    }
                )
            }
            .confirmationDialog(
                "Retire Field Division?",
                isPresented: $isShowingDeleteFieldConfirmation,
                titleVisibility: .visible,
                presenting: fieldToDelete
            ) { field in
                Button("Retire \(field.name)", role: .destructive) {
                    Task {
                        await viewModel.deleteFieldLocally(field)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { field in
                Text("Are you sure you want to retire \(field.blockCode) (\(field.name))? Historical harvest logs will remain archived.")
            }
            .toolbar {
                if requireFaceIDOnLaunch {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            HapticFeedback.selection()
                            NotificationCenter.default.post(name: Notification.Name("TeaYieldLockAppRequested"), object: nil)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 15))
                                Text("Lock")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.emerald)
                        }
                        .accessibilityLabel("Lock application immediately with Face ID")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFullProfileSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.emerald)
                    }
                    .accessibilityLabel("View full manager profile")
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

            HStack(spacing: 8) {
                Button {
                    showingFullProfileSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 13))
                        Text("Profile")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.emerald)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(AppTheme.emerald.opacity(0.08))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel("View full manager profile")

                if let user = container.authService.currentUser, user.estateId != nil {
                    Button {
                        isShowingEditEstateSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 13))
                            Text("Edit Estate")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(AppTheme.radiusSmall)
                    }
                    .accessibilityLabel("Edit estate configuration")
                }
            }
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
                title: "CANOPY HEALTH DISTRIBUTION",
                subtitle: "Sentinel-2 NDVI chlorophyll reflectance spectrum",
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
            HStack(alignment: .top) {
                SectionHeaderView(
                    title: "ESTATE DIVISIONS",
                    subtitle: "Vegetative canopy health across blocks",
                    icon: "leaf.fill",
                    badge: "\(viewModel.fields.count) BLOCKS",
                    badgeColor: AppTheme.emerald
                )

                Spacer(minLength: 8)

                NavigationLink {
                    DivisionManagementView(container: container, viewModel: viewModel)
                } label: {
                    HStack(spacing: 4) {
                        Text("Manage All")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.emerald.opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel("Open full estate divisions management screen")
            }

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
                    // Preview first 3 fields on Overview, direct to DivisionManagementView for full list
                    ForEach(viewModel.fields.prefix(3)) { field in
                        ManagerFieldRowView(
                            field: field,
                            onEdit: nil,
                            onDelete: nil
                        )
                    }

                    if viewModel.fields.count > 3 {
                        NavigationLink {
                            DivisionManagementView(container: container, viewModel: viewModel)
                        } label: {
                            HStack {
                                Text("View All \(viewModel.fields.count) Divisions")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.emerald)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.emerald)
                            }
                            .padding(12)
                            .background(AppTheme.emerald.opacity(0.08))
                            .cornerRadius(AppTheme.radiusMedium)
                        }
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
            ZStack {
                Circle()
                    .fill(color.opacity(0.14))
                    .frame(width: 36, height: 36)

                Text("\(count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(statusSubtitle(for: title))
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private func statusSubtitle(for title: String) -> String {
        switch title {
        case "Ready": return "Harvest"
        case "Growing": return "Vegetative"
        case "Resting": return "Dormant"
        default: return "Blocks"
        }
    }

    private var teamDelegationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(
                title: "WORKFORCE & STAFF MANAGEMENT",
                subtitle: "Plucker registry & field supervisory roster",
                icon: "person.2.badge.gearshape.fill"
            )

            VStack(spacing: 10) {
                // Plucker Workforce Navigation Link Card
                NavigationLink {
                    PluckerManagementView(container: container)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 44, height: 44)

                            Image(systemName: "person.3.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 18, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text("Plucker Harvesters")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(viewModel.availablePluckersCount) Enrolled")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.emerald)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.emerald.opacity(0.12))
                                    .cornerRadius(AppTheme.radiusSmall)
                            }

                            Text("Manage plucker registry, daily rates, and duty status")
                                .font(.appCaption)
                                .foregroundColor(.secondary)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
                }
                .accessibilityLabel("Open plucker workforce management")

                // Field Supervisors Navigation Link Card
                NavigationLink {
                    SupervisorManagementView(container: container)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                                .fill(AppTheme.emerald.opacity(0.12))
                                .frame(width: 44, height: 44)

                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(AppTheme.emerald)
                                .font(.system(size: 18, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text("Field Supervisors")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Spacer()

                                HStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("Invite")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.emerald)
                                .cornerRadius(AppTheme.radiusSmall)
                            }

                            Text("Provision and monitor subordinate field superintendents")
                                .font(.appCaption)
                                .foregroundColor(.secondary)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
                }
                .accessibilityLabel("Open field supervisor delegation and roster")
            }
        }
    }
}

// MARK: - Previews

struct ManagerOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerOverviewView(container: AppContainer.shared)
    }
}



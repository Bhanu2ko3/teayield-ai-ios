import SwiftUI

/// Executive oversight dashboard for estate managers and agronomists coordinating macro yield and factory intake.
struct ManagerOverviewView: View {

    @StateObject private var viewModel: ManagerOverviewViewModel
    private let container: AppContainerProtocol

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
                        estateMacroKpiGrid
                        ndviDistributionSection
                        estateDivisionsSection
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
            .toolbar {
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
            .task {
                await viewModel.loadEstateTelemetry()
            }
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
            Text("VEGETATIVE HEALTH DISTRIBUTION (SENTINEL-2 NDVI)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            HStack(spacing: 10) {
                statusPill(title: "Ready", count: viewModel.readyFieldsCount, color: AppTheme.emerald)
                statusPill(title: "Growing", count: viewModel.growingFieldsCount, color: AppTheme.amber)
                statusPill(title: "Resting", count: viewModel.restingFieldsCount, color: AppTheme.crimson)
            }
        }
    }

    private var estateDivisionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ESTATE DIVISIONS & NDVI SATELLITE STATUS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                Spacer()

                Text("\(viewModel.fields.count) Divisions")
                    .font(.appBadge)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(viewModel.fields) { field in
                    ManagerFieldRowView(field: field)
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
}


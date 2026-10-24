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
                    VStack(spacing: 20) {
                        managerProfileHeader
                        FactoryIntakeCardView(
                            currentIntakeKg: viewModel.totalHarvestTodayKg,
                            capacityCapKg: viewModel.factoryIntakeCapKg,
                            utilizationRatio: viewModel.factoryUtilizationRatio
                        )
                        estateMacroKpiRow
                        ndviDistributionSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.loadEstateTelemetry()
                }
            }
            .navigationTitle("Executive Overview")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        viewModel.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .task {
                await viewModel.loadEstateTelemetry()
            }
        }
    }

    // MARK: - Subviews

    private var managerProfileHeader: some View {
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
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var estateMacroKpiRow: some View {
        HStack(spacing: 12) {
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

            kpiCard(
                title: "Daily Intake",
                value: String(format: "%.0f kg", viewModel.totalHarvestTodayKg),
                icon: "scalemass.fill",
                tint: .purple
            )
        }
    }

    private var ndviDistributionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VEGETATIVE HEALTH DISTRIBUTION (SENTINEL-2 NDVI)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            HStack(spacing: 12) {
                statusPill(title: "Ready", count: viewModel.readyFieldsCount, color: AppTheme.emerald)
                statusPill(title: "Growing", count: viewModel.growingFieldsCount, color: AppTheme.amber)
                statusPill(title: "Resting", count: viewModel.restingFieldsCount, color: AppTheme.crimson)
            }
        }
    }

    private func kpiCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(tint)
                .font(.system(size: 14))

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

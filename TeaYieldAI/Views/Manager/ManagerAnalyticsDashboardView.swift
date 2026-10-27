import SwiftUI

/// Executive analytics canvas providing macro yield telemetry, prediction accuracy metrics, and Swift Charts.
struct ManagerAnalyticsDashboardView: View {

    @ObservedObject var viewModel: ManagerOverviewViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                kpiSummaryRow
                YieldComparisonChartView(data: viewModel.weeklyYieldComparisons)
                FactoryCapacityChartView(
                    currentIntakeKg: viewModel.totalHarvestTodayKg,
                    capacityCapKg: viewModel.factoryIntakeCapKg,
                    utilizationRatio: viewModel.factoryUtilizationRatio,
                    remainingCapacityKg: viewModel.remainingCapacityKg
                )
                NDVITrendChartView(data: viewModel.ndviTrendData)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Harvest Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var kpiSummaryRow: some View {
        HStack(spacing: 12) {
            analyticsKpiCard(
                title: "Weekly Intake",
                value: String(format: "%.0f kg", viewModel.weeklyTotalHarvestKg),
                subtext: "TRI Estate Cycle",
                icon: "scalemass.fill",
                tint: AppTheme.emerald
            )

            analyticsKpiCard(
                title: "AI Forecast Accuracy",
                value: String(format: "%.1f%%", viewModel.forecastAccuracyPercentage),
                subtext: "LSTM Deep Engine",
                icon: "bolt.badge.clock.fill",
                tint: .blue
            )

            analyticsKpiCard(
                title: "Avg Fine Leaf",
                value: String(format: "%.1f%%", viewModel.averageFineLeafPercentage),
                subtext: "Auction Benchmark 85%",
                icon: "leaf.fill",
                tint: AppTheme.emerald
            )
        }
    }

    private func analyticsKpiCard(
        title: String,
        value: String,
        subtext: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(tint)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)

            Text(subtext)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(tint)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(subtext)")
    }
}

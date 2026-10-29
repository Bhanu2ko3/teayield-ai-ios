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
                geneticOptimizerSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Harvest Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .applyAppTheme()
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

    // MARK: - Genetic Algorithm Workforce Optimization View

    private var geneticOptimizerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "cpu.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Workforce Schedule Optimizer")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Multi-constraint combinatorial Genetic Algorithm")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            if let roster = viewModel.activeRoster {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Workforce Utilization")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f%%", roster.workforceUtilizationPct))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.emerald)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("6-Day Planned Yield")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f kg", roster.totalPlannedYieldKg))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                    }

                    if !roster.days.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Daily Shift Allocations (Mon - Sat)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)

                            ForEach(roster.days) { day in
                                HStack {
                                    Text(day.dayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .frame(width: 80, alignment: .leading)

                                    Text("\(day.totalAssignedPluckers) pluckers")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Text(String(format: "%.0f kg target", day.estimatedDailyIntakeKg))
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppTheme.emerald)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.5))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            } else {
                Text("Execute the backend Genetic Algorithm optimizer to generate a balanced 6-day plucker allocation schedule conforming to factory withering throughput ceilings.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Button {
                HapticFeedback.mediumImpact()
                Task {
                    await viewModel.optimizeWorkforceRoster()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isOptimizingRoster {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    Text(viewModel.isOptimizingRoster ? "Optimizing Schedule..." : (viewModel.activeRoster == nil ? "Run Genetic Algorithm Roster Optimization" : "Re-run Roster Optimization"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(viewModel.isOptimizingRoster ? Color.gray : AppTheme.emerald)
                .foregroundColor(.white)
                .cornerRadius(AppTheme.radiusMedium)
            }
            .disabled(viewModel.isOptimizingRoster)
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

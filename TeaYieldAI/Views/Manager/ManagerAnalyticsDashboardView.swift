import SwiftUI

/// Executive analytics canvas providing macro yield telemetry, prediction accuracy metrics, and Swift Charts.
struct ManagerAnalyticsDashboardView: View {

    @ObservedObject var viewModel: ManagerOverviewViewModel
    @State private var generatedPDFData: Data? = nil
    @State private var isShowingShareSheet: Bool = false
    @State private var isGeneratingPDF: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                kpiSummaryRow
                aiForecastSection
                YieldComparisonChartView(
                    data: viewModel.weeklyYieldComparisons,
                    targetBenchmarkKg: viewModel.dailyIntakeTargetBenchmarkKg
                )
                FactoryCapacityChartView(
                    currentIntakeKg: viewModel.totalHarvestTodayKg,
                    capacityCapKg: viewModel.factoryIntakeCapKg,
                    utilizationRatio: viewModel.factoryUtilizationRatio,
                    remainingCapacityKg: viewModel.remainingCapacityKg
                )
                NDVITrendChartView(
                    data: viewModel.ndviTrendData,
                    fields: viewModel.fields
                )
                geneticOptimizerSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Harvest Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ThemeToggleView(style: .circle)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
        .refreshable {
            await viewModel.loadEstateTelemetry()
        }
        .task {
            await viewModel.loadEstateTelemetry()
        }
        .alert("Analytics & Optimization Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected analytics error occurred.")
        }
        .applyAppTheme()
    }

    // MARK: - Subviews

    private var kpiSummaryRow: some View {
        HStack(spacing: 12) {
            analyticsKpiCard(
                title: "Weekly Intake",
                value: String(format: "%.0f kg", viewModel.weeklyTotalHarvestKg),
                subtext: viewModel.weeklyTotalHarvestKg > 0 ? "Verified Intake" : "TRI Estate Cycle",
                icon: "scalemass.fill",
                tint: AppTheme.emerald
            )

            analyticsKpiCard(
                title: viewModel.hasVerifiedWeighIns ? "LSTM Accuracy" : "Model Confidence",
                value: String(format: "%.1f%%", viewModel.forecastAccuracyPercentage),
                subtext: viewModel.hasVerifiedWeighIns ? "Evaluated vs Intake" : "Temporal Sequence",
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

    // MARK: - Deep Learning LSTM Yield Prediction View

    private var aiForecastSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Harvest Yield Forecast (LSTM)")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Multivariate temporal LSTM model with Sentinel-2 NDVI telemetry")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            if let predictionMsg = viewModel.predictionSuccessMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.emerald)
                    Text(predictionMsg)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.emerald.opacity(0.12))
                .cornerRadius(AppTheme.radiusSmall)
            }

            if let batch = viewModel.activePredictionBatch {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Forecast")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f kg", batch.totalPredictedYieldKg))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.emerald)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(AppTheme.radiusMedium)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Target Week")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(batch.targetWeekStart)
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(AppTheme.radiusMedium)
                    }

                    if !batch.predictions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Field-by-Field Prediction Breakdown")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)

                            ForEach(batch.predictions) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.fieldName)
                                            .font(.system(size: 12, weight: .semibold))
                                        Text("\(item.growthStatus) • \(String(format: "NDVI %.2f", item.recentNDVI)) • \(String(format: "%.1f mm Rain", item.weatherSummary.cumulativeRainfallMm))")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(String(format: "%.1f kg", item.predictedYieldKg))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.emerald)

                                        Text(String(format: "%.0f%% Conf", item.confidenceScore * 100.0))
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.5))
                                .cornerRadius(AppTheme.radiusSmall)
                            }
                        }
                    }
                }
            } else {
                Text("Dispatch live inference request to the cloud LSTM engine to predict weekly harvestable crop volumes and microclimate factors for all estate fields.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            TeaYieldButton(
                title: viewModel.isPredictingYield ? "Running LSTM Inference..." : (viewModel.activePredictionBatch == nil ? "Generate Crop Forecast" : "Refresh Forecast"),
                icon: "chart.line.uptrend.xyaxis",
                style: .primary,
                isLoading: viewModel.isPredictingYield
            ) {
                Task {
                    await viewModel.generateAICropForecast()
                }
            }
            .disabled(viewModel.isPredictingYield)
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    // MARK: - Genetic Algorithm Workforce Optimization View

    private var geneticOptimizerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "cpu.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plucking Schedule Optimizer")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Multi-constraint combinatorial plucker allocation engine")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            if let successMsg = viewModel.optimizationSuccessMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.emerald)
                    Text(successMsg)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.emerald.opacity(0.12))
                .cornerRadius(AppTheme.radiusSmall)
            }

            // Dynamic Plucker Labor Input
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Active Plucker Labor Pool")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Available harvesters for genetic schedule")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(viewModel.availablePluckersCount)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.emerald)

                        Text("pluckers")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .fixedSize()

                    HStack(spacing: 0) {
                        Button {
                            if viewModel.availablePluckersCount > 1 {
                                viewModel.availablePluckersCount -= 1
                                HapticFeedback.selection()
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(viewModel.availablePluckersCount > 1 ? .primary : .secondary.opacity(0.4))
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .disabled(viewModel.availablePluckersCount <= 1)

                        Divider()
                            .frame(height: 16)

                        Button {
                            if viewModel.availablePluckersCount < 500 {
                                viewModel.availablePluckersCount += 1
                                HapticFeedback.selection()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(viewModel.availablePluckersCount < 500 ? .primary : .secondary.opacity(0.4))
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .disabled(viewModel.availablePluckersCount >= 500)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
            }
            .padding(12)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .cornerRadius(AppTheme.radiusMedium)

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
                        .cornerRadius(AppTheme.radiusMedium)

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
                        .cornerRadius(AppTheme.radiusMedium)
                    }

                    if !roster.days.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Shift Allocations & Division Assignments (Mon - Sat)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)

                            ForEach(roster.days) { day in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(day.dayName)
                                            .font(.system(size: 12, weight: .bold))
                                            .frame(width: 80, alignment: .leading)

                                        Text("\(day.totalAssignedPluckers) pluckers")
                                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Text(String(format: "%.0f kg target", day.estimatedDailyIntakeKg))
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.emerald)
                                    }

                                    // Detailed field assignments per day
                                    if !day.fieldAssignments.isEmpty {
                                        VStack(alignment: .leading, spacing: 3) {
                                            ForEach(day.fieldAssignments) { assignment in
                                                HStack(spacing: 4) {
                                                    Circle()
                                                        .fill(AppTheme.emerald)
                                                        .frame(width: 4, height: 4)
                                                    Text(assignment.fieldName)
                                                        .font(.system(size: 10, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                    Spacer()
                                                    Text("\(assignment.assignedPluckers) pluckers • \(String(format: "%.0f kg", assignment.targetHarvestKg))")
                                                        .font(.system(size: 10, design: .rounded))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .padding(.leading, 8)
                                        .padding(.top, 2)
                                    } else {
                                        // Dynamic division recommendation based on ready/growing fields
                                        let suggestedFields = viewModel.fields.filter { $0.status == .ready }
                                        let fieldNames = suggestedFields.isEmpty ? viewModel.fields.prefix(2).map { $0.name }.joined(separator: ", ") : suggestedFields.prefix(2).map { $0.name }.joined(separator: ", ")
                                        if !fieldNames.isEmpty {
                                            HStack(spacing: 4) {
                                                Image(systemName: "leaf.fill")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(AppTheme.emerald)
                                                Text("Assigned: \(fieldNames)")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                            .padding(.leading, 8)
                                        }
                                    }
                                }
                                .padding(8)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.7))
                                .cornerRadius(AppTheme.radiusSmall)
                            }
                        }
                    }
                }
            } else {
                Text("Execute the backend Genetic Algorithm optimizer to generate a balanced 6-day plucker allocation schedule conforming to factory withering throughput ceilings.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 10) {
                TeaYieldButton(
                    title: viewModel.isOptimizingRoster ? "Optimizing Schedule..." : (viewModel.activeRoster == nil ? "Generate Plucking Schedule" : "Re-optimize Plucking Schedule"),
                    icon: "calendar.badge.clock",
                    style: .primary,
                    isLoading: viewModel.isOptimizingRoster
                ) {
                    Task {
                        await viewModel.optimizeWorkforceRoster()
                    }
                }
                .disabled(viewModel.isOptimizingRoster)

                if let roster = viewModel.activeRoster {
                    TeaYieldButton(
                        title: isGeneratingPDF ? "Preparing Official Document..." : "Export Official PDF Roster",
                        icon: "doc.text.fill",
                        style: .secondary,
                        isLoading: isGeneratingPDF
                    ) {
                        exportRosterPDF(roster: roster)
                    }
                    .disabled(isGeneratingPDF)
                }
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .sheet(isPresented: $isShowingShareSheet) {
            if let pdfData = generatedPDFData {
                let tempURL = saveTempPDF(data: pdfData)
                ShareSheet(activityItems: [tempURL])
            }
        }
    }

    private func exportRosterPDF(roster: RosterOptimizationResponseDTO) {
        isGeneratingPDF = true
        HapticFeedback.lightImpact()

        DispatchQueue.global(qos: .userInitiated).async {
            let estateName = viewModel.estateDisplayName
            let fieldNames = viewModel.fields.map { "\($0.name) (\($0.blockCode))" }
            let data = RosterPDFGenerator.generatePDF(
                roster: roster,
                estateName: estateName,
                district: "Central Highlands",
                managerName: "Estate Superintendent",
                fieldDivisions: fieldNames
            )

            DispatchQueue.main.async {
                self.generatedPDFData = data
                self.isGeneratingPDF = false
                self.isShowingShareSheet = true
                HapticFeedback.success()
            }
        }
    }

    private func saveTempPDF(data: Data) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "TeaYield_Plucking_Roster_\(Date().formatted(date: .numeric, time: .omitted)).pdf"
            .replacingOccurrences(of: "/", with: "-")
        let fileURL = tempDir.appendingPathComponent(fileName)
        try? data.write(to: fileURL)
        return fileURL
    }
}

// MARK: - Previews

struct ManagerAnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ManagerAnalyticsDashboardView(
                viewModel: ManagerOverviewViewModel(
                    fieldRepository: AppContainer.shared.fieldRepository,
                    harvestRepository: AppContainer.shared.harvestRepository,
                    authService: AppContainer.shared.authService,
                    apiService: AppContainer.shared.apiService
                )
            )
        }
    }
}


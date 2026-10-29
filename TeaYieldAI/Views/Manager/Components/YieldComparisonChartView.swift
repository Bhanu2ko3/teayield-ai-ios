import SwiftUI
import Charts

/// Interactive Swift Charts visualization comparing 7-day AI predicted yield against actual harvested green leaf intake.
struct YieldComparisonChartView: View {

    let data: [DailyYieldComparison]
    @State private var selectedDay: DailyYieldComparison?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerSection
            chartContainer
            if let selected = selectedDay {
                selectedDayInspectorCard(for: selected)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("7-Day Yield Comparison Chart: Total predicted \(Int(totalPredictedKg)) kg, total actual \(Int(totalActualKg)) kg")
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("7-Day Yield Performance")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Spacer()

                legendPill(title: "AI Predicted", color: .blue)
                legendPill(title: "Actual Intake", color: AppTheme.emerald)
            }

            Text("Comparison of LSTM daily predictions against verified weigh-in records")
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
    }

    private var chartContainer: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Day", item.dayName),
                    y: .value("Weight", item.predictedYieldKg)
                )
                .foregroundStyle(Color.blue.opacity(0.85))
                .position(by: .value("Type", "Predicted"))

                BarMark(
                    x: .value("Day", item.dayName),
                    y: .value("Weight", item.actualHarvestedKg)
                )
                .foregroundStyle(AppTheme.emerald)
                .position(by: .value("Type", "Actual"))
            }

            RuleMark(y: .value("TRI Target", 750.0))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(Color.orange.opacity(0.8))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Target 750 kg")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.9))
                        .cornerRadius(AppTheme.radiusSmall)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue) kg")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let stringValue = value.as(String.self) {
                        Text(stringValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .frame(height: 200)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { location in
                                handleChartTap(at: location.location, proxy: proxy, geometry: geometry)
                            }
                    )
            }
        }
    }

    private func selectedDayInspectorCard(for day: DailyYieldComparison) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(day.dayName)
                    .font(.appHeadline)
                    .foregroundColor(.primary)
                Text("Selected Shift")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Predicted:")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f kg", day.predictedYieldKg))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }

                HStack(spacing: 4) {
                    Text("Harvested:")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f kg", day.actualHarvestedKg))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(day.formattedVariance)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(day.varianceKg >= 0 ? AppTheme.emerald : AppTheme.crimson)
                Text(String(format: "%.0f%% target", day.achievementRatio * 100.0))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func legendPill(title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private func handleChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let plotFrame = geometry[proxy.plotAreaFrame]
        guard plotFrame.contains(location) else { return }
        let plotX = location.x - plotFrame.origin.x
        guard let xValue: String = proxy.value(atX: plotX) else { return }
        if let matched = data.first(where: { $0.dayName == xValue }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedDay?.id == matched.id {
                    selectedDay = nil
                } else {
                    selectedDay = matched
                    HapticFeedback.lightImpact()
                }
            }
        }
    }

    private var totalPredictedKg: Double {
        data.reduce(0.0) { $0 + $1.predictedYieldKg }
    }

    private var totalActualKg: Double {
        data.reduce(0.0) { $0 + $1.actualHarvestedKg }
    }
}

// MARK: - Previews

struct YieldComparisonChartView_Previews: PreviewProvider {
    static var previews: some View {
        YieldComparisonChartView(data: [
            DailyYieldComparison(dayName: "Mon", date: Date(), predictedYieldKg: 650, actualHarvestedKg: 700),
            DailyYieldComparison(dayName: "Tue", date: Date(), predictedYieldKg: 700, actualHarvestedKg: 680),
            DailyYieldComparison(dayName: "Wed", date: Date(), predictedYieldKg: 720, actualHarvestedKg: 750),
            DailyYieldComparison(dayName: "Thu", date: Date(), predictedYieldKg: 690, actualHarvestedKg: 710)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


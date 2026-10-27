import SwiftUI
import Charts

/// Executive chart component displaying factory green leaf intake allocation against processing threshold.
struct FactoryCapacityChartView: View {

    let currentIntakeKg: Double
    let capacityCapKg: Double
    let utilizationRatio: Double
    let remainingCapacityKg: Double

    struct IntakeSegment: Identifiable {
        let id = UUID()
        let label: String
        let weightKg: Double
        let color: Color
    }

    private var segments: [IntakeSegment] {
        let statusColor: Color
        if utilizationRatio >= 0.90 {
            statusColor = AppTheme.crimson
        } else if utilizationRatio >= 0.75 {
            statusColor = AppTheme.amber
        } else {
            statusColor = AppTheme.emerald
        }

        return [
            IntakeSegment(label: "Current Leaf Intake", weightKg: currentIntakeKg, color: statusColor),
            IntakeSegment(label: "Available Headroom", weightKg: remainingCapacityKg, color: Color.secondary.opacity(0.18))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerSection
            stackedBarChart
            metricsFooter
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Factory withering intake: \(Int(currentIntakeKg)) kg of \(Int(capacityCapKg)) kg, \(Int(utilizationRatio * 100)) percent utilized")
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Factory Withering Capacity")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Central Trough Aeration Line Intake")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.0f%% Cap", utilizationRatio * 100.0))
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(utilizationColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(utilizationColor.opacity(0.12))
                .cornerRadius(6)
        }
    }

    private var stackedBarChart: some View {
        Chart(segments) { segment in
            BarMark(
                x: .value("Weight", segment.weightKg),
                y: .value("Metric", "Withering Line")
            )
            .foregroundStyle(segment.color)
        }
        .chartXScale(domain: 0...max(capacityCapKg, currentIntakeKg))
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue) kg")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: 38)
    }

    private var metricsFooter: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(utilizationColor)
                    .frame(width: 8, height: 8)
                Text("Received: \(String(format: "%.0f kg", currentIntakeKg))")
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                Text("Remaining: \(String(format: "%.0f kg", remainingCapacityKg))")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var utilizationColor: Color {
        if utilizationRatio >= 0.90 {
            return AppTheme.crimson
        } else if utilizationRatio >= 0.75 {
            return AppTheme.amber
        } else {
            return AppTheme.emerald
        }
    }
}

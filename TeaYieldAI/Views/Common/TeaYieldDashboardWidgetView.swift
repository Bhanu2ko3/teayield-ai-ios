import SwiftUI

/// High-fidelity, modern agricultural telemetry widget view designed for quick glanceability.
/// Reusable across both Home/Dashboard views and lock screen / desktop companion widgets.
struct TeaYieldDashboardWidgetView: View {

    let targetYieldKg: Double
    let harvestedKg: Double
    let readyFieldsCount: Int
    let fineLeafRatioPercent: Double
    let estateName: String

    var progress: Double {
        guard targetYieldKg > 0 else { return 0 }
        return min(1.0, harvestedKg / targetYieldKg)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.emerald)
                    Text("TeaYield AI")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(estateName)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Divider()

            // Main Metrics Section
            HStack(spacing: 16) {
                // Circular Ring Progress
                ZStack {
                    Circle()
                        .stroke(AppTheme.emerald.opacity(0.18), lineWidth: 6)
                        .frame(width: 54, height: 54)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            AppTheme.emerald,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 54, height: 54)
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    VStack(spacing: 0) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }

                // Metric Text Details
                VStack(alignment: .leading, spacing: 4) {
                    Text("Harvest Intake")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(String(format: "%.0f", harvestedKg))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("/ \(String(format: "%.0f", targetYieldKg)) kg")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(AppTheme.emerald)
                                .frame(width: 6, height: 6)
                            Text("\(readyFieldsCount) Ready")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.emerald)
                        }

                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.forest)
                            Text(String(format: "%.1f%% Quality", fineLeafRatioPercent))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

// MARK: - Previews

struct TeaYieldDashboardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TeaYieldDashboardWidgetView(
            targetYieldKg: 750,
            harvestedKg: 520,
            readyFieldsCount: 2,
            fineLeafRatioPercent: 88.4,
            estateName: "Great Western Valley"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

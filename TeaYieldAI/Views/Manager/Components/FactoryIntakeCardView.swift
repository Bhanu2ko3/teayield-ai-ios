import SwiftUI

/// Executive telemetry card monitoring factory withering trough intake against mountain overloading caps.
struct FactoryIntakeCardView: View {

    let currentIntakeKg: Double
    let capacityCapKg: Double
    let utilizationRatio: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FACTORY INTAKE MONITOR")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)

                    Text("Withering Trough Safety Cap")
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(String(format: "%.0f%%", utilizationRatio * 100))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(statusTint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusTint.opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)
            }

            // Progress Gauge
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(height: 10)

                    Capsule()
                        .fill(statusTint)
                        .frame(width: geo.size.width * CGFloat(utilizationRatio), height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text(String(format: "Current: %.0f kg", currentIntakeKg))
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(String(format: "Cap: %.0f kg", capacityCapKg))
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var statusTint: Color {
        if utilizationRatio >= 0.90 {
            return AppTheme.crimson
        } else if utilizationRatio >= 0.75 {
            return AppTheme.amber
        } else {
            return AppTheme.emerald
        }
    }
}

import SwiftUI

/// Executive telemetry card monitoring factory withering trough intake against mountain overloading caps.
struct FactoryIntakeCardView: View {

    let currentIntakeKg: Double
    let capacityCapKg: Double
    let utilizationRatio: Double
    let remainingCapacityKg: Double

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

                Text(statusBadgeTitle)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
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
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(utilizationRatio))), height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text(String(format: "Intake: %.0f kg", currentIntakeKg))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Spacer()

                Text(String(format: "Remaining: %.0f kg", remainingCapacityKg))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(remainingCapacityKg < 500 ? AppTheme.crimson : .secondary)

                Spacer()

                Text(String(format: "Cap: %.0f kg", capacityCapKg))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Factory withering trough monitor: current intake \(Int(currentIntakeKg)) kg of \(Int(capacityCapKg)) kg capacity, \(Int(utilizationRatio * 100)) percent utilized, \(Int(remainingCapacityKg)) kg remaining")
    }

    private var statusBadgeTitle: String {
        if utilizationRatio >= 0.90 {
            return "CONGESTION WARNING"
        } else if utilizationRatio >= 0.75 {
            return "APPROACHING CAP"
        } else {
            return String(format: "%.0f%% OPTIMAL", utilizationRatio * 100)
        }
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

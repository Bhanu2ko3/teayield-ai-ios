import SwiftUI

/// Executive summary row displaying total target yield, harvested weight, and assigned plucker counts.
struct KpiSummaryRowView: View {

    let targetKg: Double
    let harvestedKg: Double
    let pluckersTotal: Int

    var body: some View {
        HStack(spacing: 12) {
            kpiCard(
                title: "Target Yield",
                value: String(format: "%.0f kg", targetKg),
                icon: "target",
                tintColor: .blue
            )

            kpiCard(
                title: "Harvested",
                value: String(format: "%.0f kg", harvestedKg),
                icon: "scalemass.fill",
                tintColor: AppTheme.emerald
            )

            kpiCard(
                title: "Pluckers",
                value: "\(pluckersTotal)",
                icon: "person.2.fill",
                tintColor: .purple
            )
        }
    }

    private func kpiCard(title: String, value: String, icon: String, tintColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(tintColor)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }
}

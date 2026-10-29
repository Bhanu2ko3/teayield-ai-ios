import SwiftUI

/// Executive summary row displaying total target yield, harvested weight, and assigned plucker counts.
/// Strictly conforms to Section 5 Design System and unified semantic palette.
struct KpiSummaryRowView: View {

    let targetKg: Double
    let harvestedKg: Double
    let pluckersTotal: Int

    var body: some View {
        HStack(spacing: 10) {
            kpiCard(
                title: "Target Yield",
                value: String(format: "%.0f kg", targetKg),
                icon: "target",
                tintColor: AppTheme.forest
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
                tintColor: AppTheme.amber
            )
        }
    }

    private func kpiCard(title: String, value: String, icon: String, tintColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(tintColor)
                Spacer()
            }

            Text(value)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Previews

struct KpiSummaryRowView_Previews: PreviewProvider {
    static var previews: some View {
        KpiSummaryRowView(
            targetKg: 850.0,
            harvestedKg: 780.0,
            pluckersTotal: 30
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

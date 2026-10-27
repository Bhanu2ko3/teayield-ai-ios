import SwiftUI

/// Card row rendering individual estate tea field divisions with NDVI index and harvest readiness.
struct ManagerFieldRowView: View {

    let field: TeaField

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor(for: field.status))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(field.name)
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Block: \(field.blockCode) • Acreage: \(field.formattedAcreage)")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(field.status.rawValue)
                    .font(.appBadge)
                    .foregroundColor(statusColor(for: field.status))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(statusColor(for: field.status).opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)

                Text("NDVI: \(field.formattedNDVI)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(field.name), Block \(field.blockCode), Acreage \(field.formattedAcreage), Readiness Status \(field.status.rawValue), NDVI score \(field.formattedNDVI)")
    }

    private func statusColor(for status: FieldReadinessStatus) -> Color {
        switch status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }
}

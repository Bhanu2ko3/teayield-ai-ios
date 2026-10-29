import SwiftUI

/// Standardized section header component conforming to Section 5.4 typography guidelines.
/// Establishes uniform section labeling, optional domain subtitles, and telemetry indicators across all screens.
struct SectionHeaderView: View {

    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var badge: String? = nil
    var badgeColor: Color = AppTheme.emerald

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.emerald)
                }

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                if let badge = badge {
                    Text(badge.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(badgeColor.opacity(0.12))
                        .cornerRadius(AppTheme.radiusSmall)
                }
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(badge != nil ? "\(title), Status: \(badge!)" : title)
    }
}

// MARK: - Previews

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SectionHeaderView(
                title: "FACTORY WITHRING CAPACITIES",
                subtitle: "Real-time green leaf intake against factory daily ceiling",
                icon: "scalemass.fill",
                badge: "Optimal 70%",
                badgeColor: AppTheme.emerald
            )

            SectionHeaderView(
                title: "SPATIAL FIELD ROSTER",
                subtitle: "Assigned plucking divisions for current morning shift",
                icon: "map.fill"
            )

            SectionHeaderView(
                title: "BIOMETRIC VAULT TIER",
                badge: "Face ID Enabled",
                badgeColor: .blue
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


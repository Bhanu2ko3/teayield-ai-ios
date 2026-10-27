import SwiftUI

/// Card row rendering individual green leaf harvest weigh-ins with quality grade and sync badges.
struct HarvestRecordRowView: View {

    let record: HarvestRecord

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(record.pluckerName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("ID: \(record.pluckerId)")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(record.formattedNetWeight)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)

                    Text("Net Weight")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                HStack(spacing: 6) {
                    Text(record.qualityGrade)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(qualityBadgeColor.opacity(0.12))
                        .foregroundColor(qualityBadgeColor)
                        .cornerRadius(AppTheme.radiusSmall)

                    Text("Fine Leaf: \(record.formattedFineLeafPercentage)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: record.isSynced ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                    Text(record.isSynced ? "Synced" : "Offline")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                }
                .foregroundColor(record.isSynced ? AppTheme.emerald : AppTheme.amber)
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.pluckerName), Employee ID \(record.pluckerId), Net Weight \(record.formattedNetWeight), Quality Grade \(record.qualityGrade), Fine leaf ratio \(record.formattedFineLeafPercentage), Status \(record.isSynced ? "Synced" : "Pending Sync")")
    }

    private var qualityBadgeColor: Color {
        if record.fineLeafRatio >= AppConfiguration.fineLeafTargetRatio {
            return AppTheme.emerald
        } else if record.fineLeafRatio >= 0.70 {
            return AppTheme.amber
        } else {
            return AppTheme.crimson
        }
    }
}

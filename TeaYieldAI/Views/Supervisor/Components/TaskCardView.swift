import SwiftUI

/// Card presentation displaying a daily plucking task, field acreage, plucker quota, and progress.
struct TaskCardView: View {

    let task: PluckingTask
    var isGeofenced: Bool = false
    let onRecordWeighingTap: () -> Void
    var onSimulateArrivalTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            quotaProgressSection
            actionFooterRow
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.fieldName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(task.blockCode)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                if isGeofenced {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 8))
                        Text("IN GEOFENCE")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppTheme.emerald.opacity(0.15))
                    .foregroundColor(AppTheme.emerald)
                    .cornerRadius(6)
                }

                statusBadge
            }
        }
    }

    private var statusBadge: some View {
        Text(task.isCompleted ? "COMPLETED" : "IN PROGRESS")
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.12))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }

    private var quotaProgressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Target: \(task.formattedTargetWeight)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(task.formattedHarvestedWeight) Harvested")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color(red: 0.02, green: 0.59, blue: 0.41))
                        .frame(
                            width: max(0, min(proxy.size.width, proxy.size.width * CGFloat(task.progressRatio))),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
    }

    private var actionFooterRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(task.assignedPluckersCount) Pluckers Assigned")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let onSimulateArrivalTap = onSimulateArrivalTap {
                Button(action: onSimulateArrivalTap) {
                    Image(systemName: isGeofenced ? "location.fill" : "dot.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundColor(isGeofenced ? AppTheme.emerald : .secondary)
                        .padding(7)
                        .background(isGeofenced ? AppTheme.emerald.opacity(0.12) : Color.secondary.opacity(0.08))
                        .cornerRadius(8)
                }
                .accessibilityLabel(isGeofenced ? "Simulate Geofence Exit" : "Simulate Geofence Arrival")
                .accessibilityHint("Triggers on-device CoreLocation boundary event for Viva testing")
            }

            Button(action: onRecordWeighingTap) {
                HStack(spacing: 6) {
                    Image(systemName: "scalemass.fill")
                        .font(.caption)
                    Text("Weigh Leaf")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.emerald)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        task.isCompleted ? AppTheme.emerald : Color.blue
    }
}

import SwiftUI

/// Bottom sheet drawer displaying real-time field GIS telemetry, NDVI index, and weighing action button.
struct FieldDetailBottomSheetView: View {

    let field: TeaField
    var isCurrentlyGeofenced: Bool = false
    var onWeighTap: ((TeaField) -> Void)?
    var onSimulateGeofenceTap: ((TeaField) -> Void)?
    var onCloseTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            // Drag handle and top close button bar
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 36, height: 4)
                    .padding(.leading, 28) // Offset to center relative to close button
                Spacer()

                if let onCloseTap = onCloseTap {
                    Button(action: {
                        HapticFeedback.lightImpact()
                        onCloseTap()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Dismiss field details")
                }
            }
            .padding(.top, 4)

            // Header Row: Field Title, Code, and Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(field.name)
                        .font(.appHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Division Block: \(field.blockCode)")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                statusBadge
            }

            if isCurrentlyGeofenced {
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 8, height: 8)
                    Text("Supervisor Inside Field Geofence")
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.emerald)
                    Spacer()
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(AppTheme.emerald.opacity(0.10))
                .cornerRadius(AppTheme.radiusSmall)
            }

            // 3 KPI Metric Cards
            HStack(spacing: 8) {
                metricTile(
                    title: "Acreage",
                    value: field.formattedAcreage,
                    icon: "square.dashed"
                )
                metricTile(
                    title: "Canopy NDVI",
                    value: field.formattedNDVI,
                    icon: "leaf.fill",
                    tint: statusColor
                )
                metricTile(
                    title: "Est. Target",
                    value: String(format: "%.0f kg", field.acreage * AppConfiguration.benchmarkYieldPerAcreKg),
                    icon: "scalemass.fill"
                )
            }

            // NDVI Satellite Health Bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Sentinel-2 Chlorophyll Index")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(field.status.displayName)
                        .font(.appCaption)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)

                        Capsule()
                            .fill(statusColor)
                            .frame(width: max(geo.size.width * CGFloat(min(max(field.currentNDVI, 0), 1.0)), 0), height: 6)
                    }
                }
                .frame(height: 6)
            }

            // Primary Action Button: "Record Harvest from Block"
            if let onWeighTap = onWeighTap {
                Button(action: {
                    HapticFeedback.lightImpact()
                    onWeighTap(field)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Record Harvest from \(field.blockCode)")
                            .font(.appHeadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(field.status == .ready ? AppTheme.emerald : AppTheme.amber)
                    .cornerRadius(AppTheme.radiusMedium)
                }
                .accessibilityLabel("Record harvest weighing for \(field.name), block \(field.blockCode)")
                .accessibilityHint("Opens weighing entry form pre-selected with this field")
            }

            // Secondary Viva Simulation Button: "Simulate Geofence Arrival"
            if let onSimulateGeofenceTap = onSimulateGeofenceTap {
                Button(action: {
                    HapticFeedback.lightImpact()
                    onSimulateGeofenceTap(field)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isCurrentlyGeofenced ? "checkmark.circle.fill" : "dot.radiowaves.left.and.right")
                            .font(.system(size: 12))
                        Text(isCurrentlyGeofenced ? "Geofence Active (Boundary Triggered)" : "Simulate Geofence Arrival (Viva Test)")
                            .font(.appCaption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(isCurrentlyGeofenced ? AppTheme.emerald : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel(isCurrentlyGeofenced ? "Geofence is currently active for \(field.name)" : "Simulate entering \(field.name) geofence boundary")
                .accessibilityHint("Simulates GPS hardware boundary entry for viva defense")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .shadow(color: Color.black.opacity(0.18), radius: 16, y: 6)
    }

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            Text(field.status.displayName)
                .font(.appCaption)
                .fontWeight(.bold)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.12))
        .cornerRadius(AppTheme.radiusSmall)
    }

    private var statusColor: Color {
        switch field.status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }

    private func metricTile(title: String, value: String, icon: String, tint: Color = .primary) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            Text(value)
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(tint)

            Text(title)
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.07))
        .cornerRadius(AppTheme.radiusSmall)
    }
}

// MARK: - Previews

struct FieldDetailBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FieldDetailBottomSheetView(
            field: MockData.fieldBlockA,
            isCurrentlyGeofenced: true
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


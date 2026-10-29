import SwiftUI

/// Bottom sheet drawer displaying real-time field GIS telemetry, NDVI index, and weighing action button.
struct FieldDetailBottomSheetView: View {

    let field: TeaField
    var isCurrentlyGeofenced: Bool = false
    var onWeighTap: ((TeaField) -> Void)?
    var onSimulateGeofenceTap: ((TeaField) -> Void)?
    var onCloseTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            // Drag handle indicator
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // Header Row: Field Title, Code, and Status Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(field.name)
                        .font(.appTitle)
                        .foregroundColor(.primary)

                    Text("Division Block: \(field.blockCode)")
                        .font(.appCallout)
                        .foregroundColor(.secondary)
                }

                Spacer()

                statusBadge
            }

            if isCurrentlyGeofenced {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 8, height: 8)
                    Text("SUPERVISOR INSIDE FIELD GEOFENCE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                    Spacer()
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.emerald.opacity(0.12))
                .cornerRadius(AppTheme.radiusSmall)
            }

            Divider()

            // 3 KPI Metric Cards
            HStack(spacing: 10) {
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
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Sentinel-2 Chlorophyll Index")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(field.status.displayName)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 8)

                        Capsule()
                            .fill(statusColor)
                            .frame(width: max(geo.size.width * CGFloat(min(max(field.currentNDVI, 0), 1.0)), 0), height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.vertical, 2)

            // Primary Action Button: "Log Harvest Weighing"
            if let onWeighTap = onWeighTap {
                Button(action: { onWeighTap(field) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "scalemass.fill")
                        Text("Record Harvest from \(field.blockCode)")
                            .fontWeight(.bold)
                    }
                    .font(.appHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(field.status == .ready ? AppTheme.emerald : AppTheme.amber)
                    .cornerRadius(AppTheme.radiusMedium)
                }
                .accessibilityLabel("Record harvest weighing for \(field.name), block \(field.blockCode)")
                .accessibilityHint("Opens weighing entry form pre-selected with this field")
                .padding(.top, 4)
            }

            // Secondary Viva Simulation Button: "Simulate Geofence Arrival"
            if let onSimulateGeofenceTap = onSimulateGeofenceTap {
                Button(action: { onSimulateGeofenceTap(field) }) {
                    HStack(spacing: 6) {
                        Image(systemName: isCurrentlyGeofenced ? "checkmark.circle.fill" : "dot.radiowaves.left.and.right")
                            .font(.system(size: 13))
                        Text(isCurrentlyGeofenced ? "Geofence Active (Boundary Triggered)" : "Simulate Geofence Arrival (Viva Test)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(isCurrentlyGeofenced ? AppTheme.emerald : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel(isCurrentlyGeofenced ? "Geofence is currently active for \(field.name)" : "Simulate entering \(field.name) geofence boundary")
                .accessibilityHint("Simulates GPS hardware boundary entry for viva defense")
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(field.status.displayName)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.12))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch field.status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }

    private func metricTile(title: String, value: String, icon: String, tint: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(tint)

            Text(title)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.08))
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


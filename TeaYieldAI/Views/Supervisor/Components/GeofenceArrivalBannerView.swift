import SwiftUI

/// Banner signaling live GPS geofence arrival at an assigned plucking field.
struct GeofenceArrivalBannerView: View {

    let fieldName: String
    let shiftDate: Date
    var onWeighTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Telemetry Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 7, height: 7)
                    Text("LIVE GEOFENCE ARRIVAL DETECTED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }

                Spacer()

                Text("±3.2m GPS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.emerald.opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)
            }

            // Main Field Details & Action Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "location.fill")
                        .foregroundColor(AppTheme.emerald)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(fieldName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(formattedDate)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 8)

                Button(action: onWeighTap) {
                    HStack(spacing: 5) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 11))
                        Text("Weigh")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.emerald)
                    .cornerRadius(AppTheme.radiusSmall)
                }
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Live Geofence Arrival Detected at \(fieldName). \(formattedDate). Double tap Weigh button to record harvest.")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Active Shift: \(formatter.string(from: shiftDate))"
    }
}

// MARK: - Previews

struct GeofenceArrivalBannerView_Previews: PreviewProvider {
    static var previews: some View {
        GeofenceArrivalBannerView(
            fieldName: "Upper Division Block A",
            shiftDate: Date(),
            onWeighTap: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


import SwiftUI

/// Banner signaling live GPS geofence arrival at an assigned plucking field.
struct GeofenceArrivalBannerView: View {

    let fieldName: String
    let shiftDate: Date
    var onWeighTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.15))
                    .frame(width: 42, height: 42)

                Image(systemName: "location.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 6, height: 6)
                    Text("LIVE GEOFENCE ARRIVAL DETECTED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }

                Text(fieldName)
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("GPS Accuracy ±3.2m • \(formattedDate)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onWeighTap) {
                HStack(spacing: 4) {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 10))
                    Text("Weigh")
                        .font(.appBadge)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppTheme.emerald)
                .cornerRadius(AppTheme.radiusSmall)
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

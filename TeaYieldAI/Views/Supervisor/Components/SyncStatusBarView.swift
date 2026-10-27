import SwiftUI

/// Top-level status banner indicating connectivity, pending offline weighing logs, and sync triggers.
struct SyncStatusBarView: View {

    let unsyncedCount: Int
    let isSyncing: Bool
    let isOffline: Bool
    let statusMessage: String?
    let onSyncTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            statusIcon
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(primaryStatusTitle)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)

                if let message = statusMessage {
                    Text(message)
                        .font(.caption2)
                        .foregroundColor(textColor.opacity(0.85))
                        .lineLimit(1)
                }
            }

            Spacer()

            if isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                    .scaleEffect(0.8)
            } else if unsyncedCount > 0 {
                Button(action: onSyncTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11, weight: .bold))
                        Text("Sync Now")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(buttonBackgroundColor)
                    .foregroundColor(buttonTextColor)
                    .cornerRadius(8)
                }
                .accessibilityLabel("Synchronize \(unsyncedCount) queued weighing records now")
                .accessibilityHint("Uploads local offline harvest logs to estate cloud")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(bannerBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sync status: \(primaryStatusTitle). \(statusMessage ?? "")")
    }

    // MARK: - Computed Styling

    private var primaryStatusTitle: String {
        if isSyncing {
            return "Synchronizing with Estate Cloud..."
        }
        if unsyncedCount > 0 {
            return "\(unsyncedCount) Weighing \(unsyncedCount == 1 ? "Record" : "Records") Queued (Offline)"
        }
        if isOffline {
            return "Offline Mode (Using Local Cache)"
        }
        return "All Harvest Logs Synchronized"
    }

    @ViewBuilder
    private var statusIcon: some View {
        if isSyncing {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(textColor)
        } else if unsyncedCount > 0 {
            Image(systemName: "tray.and.arrow.up.fill")
                .foregroundColor(textColor)
        } else if isOffline {
            Image(systemName: "wifi.slash")
                .foregroundColor(textColor)
        } else {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(textColor)
        }
    }

    private var bannerBackgroundColor: Color {
        if unsyncedCount > 0 {
            return Color.orange.opacity(0.12)
        }
        if isOffline {
            return Color.yellow.opacity(0.12)
        }
        return Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.1)
    }

    private var borderColor: Color {
        if unsyncedCount > 0 {
            return Color.orange.opacity(0.3)
        }
        if isOffline {
            return Color.yellow.opacity(0.3)
        }
        return Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.25)
    }

    private var textColor: Color {
        if unsyncedCount > 0 {
            return Color.orange
        }
        if isOffline {
            return Color(red: 0.8, green: 0.6, blue: 0.0)
        }
        return Color(red: 0.02, green: 0.59, blue: 0.41)
    }

    private var buttonBackgroundColor: Color {
        Color.orange
    }

    private var buttonTextColor: Color {
        Color.white
    }
}

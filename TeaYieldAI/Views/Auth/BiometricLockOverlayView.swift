import SwiftUI

/// Security lock screen displayed when Face ID / Touch ID biometric authentication is required.
/// Prevents dashboard content leakage prior to positive biometric verification or passcode fallback.
struct BiometricLockOverlayView: View {

    let officerName: String
    let biometryType: BiometryType
    let onUnlockTap: () -> Void

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Lock Icon Container
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 90, height: 90)

                    Image(systemName: biometryType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(AppTheme.emerald)
                }

                VStack(spacing: 8) {
                    Text("TeaYield AI Locked")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Signed in as \(officerName)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)

                    Text("Biometric verification required to access operational harvest telemetry and estate records.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.top, 4)
                }

                Spacer()

                VStack(spacing: 12) {
                    TeaYieldButton(
                        title: "Unlock with \(biometryType.rawValue)",
                        icon: biometryType == .faceID ? "faceid" : "touchid",
                        style: .primary,
                        action: onUnlockTap
                    )

                    Text("Passcode fallback enabled")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .applyAppTheme()
    }
}


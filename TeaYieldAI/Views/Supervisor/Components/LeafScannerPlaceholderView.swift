import SwiftUI

/// Placeholder view for the on-device Core ML leaf maturity camera scanner (Component 3).
struct LeafScannerPlaceholderView: View {

    var onRecordWeighingTap: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.emerald.opacity(0.12))
                            .frame(width: 120, height: 120)

                        Image(systemName: "viewfinder")
                            .font(.system(size: 56, weight: .light))
                            .foregroundColor(AppTheme.emerald)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.emerald)
                    }

                    VStack(spacing: 8) {
                        Text("Core ML Shoot Quality Scanner")
                            .font(.appTitle)
                            .foregroundColor(.primary)

                        Text("On-Device Vision • Apple Neural Engine")
                            .font(.appCallout)
                            .foregroundColor(AppTheme.emerald)
                            .fontWeight(.semibold)

                        Text("Scans tea bushes at 60fps to determine the fine-to-coarse leaf ratio (Two Leaves and a Bud) against the 85% export auction benchmark 100% offline.")
                            .font(.appBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(3)
                    }

                    HStack(spacing: 12) {
                        featureTag(icon: "bolt.fill", title: "60 FPS")
                        featureTag(icon: "wifi.slash", title: "100% Offline")
                        featureTag(icon: "checkmark.seal.fill", title: "85% Target")
                    }

                    Spacer()

                    if let onRecordWeighingTap = onRecordWeighingTap {
                        Button(action: onRecordWeighingTap) {
                            HStack(spacing: 8) {
                                Image(systemName: "scalemass.fill")
                                Text("Open Leaf Weighing Form")
                                    .font(.appHeadline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.emerald)
                            .cornerRadius(AppTheme.radiusMedium)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Leaf Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func featureTag(icon: String, title: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.emerald)
            Text(title)
                .font(.appBadge)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusSmall)
    }
}

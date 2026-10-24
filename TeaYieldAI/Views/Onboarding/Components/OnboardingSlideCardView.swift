import SwiftUI

/// Carousel slide card presenting platform capability highlights and benchmark metrics.
struct OnboardingSlideCardView: View {

    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 14) {
            Text(slide.badge)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.emerald)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.emerald.opacity(0.1))
                .cornerRadius(AppTheme.radiusSmall)

            Text(slide.title)
                .font(.appHeadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(slide.description)
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 8)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                ForEach(slide.pills) { pill in
                    VStack(spacing: 2) {
                        Text(pill.title)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.emerald)

                        Text(pill.subtitle)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusSmall)
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

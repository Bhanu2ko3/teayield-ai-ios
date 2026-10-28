import SwiftUI

/// Onboarding carousel introducing Zero-IoT satellite yield prediction, Core ML shoot vision, and GA scheduling.
/// Conforms to Figma Screen 01 (Welcome Onboarding View).
struct OnboardingView: View {

    @Binding var hasCompletedOnboarding: Bool
    @State private var currentSlide = 0
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue

    private let slides: [OnboardingSlide] = OnboardingSlide.defaultSlides

    private var currentThemeMode: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topHeaderBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer(minLength: 12)

                    brandHeroHeader
                        .padding(.horizontal, 24)

                    Spacer(minLength: 16)

                    carouselSection
                        .frame(height: 300)

                    Spacer(minLength: 12)

                    pageIndicatorDots
                        .padding(.bottom, 20)

                    bottomActionControls
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                }
            }
            .navigationBarHidden(true)
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var topHeaderBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.emerald)
                    .frame(width: 8, height: 8)

                Text("TEAYIELD AI • PRECISION")
                    .font(.appBadge)
                    .foregroundColor(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppTheme.radiusPill)

            Spacer()

            Menu {
                ForEach(AppThemeMode.allCases) { mode in
                    Button {
                        HapticFeedback.selection()
                        appThemeMode = mode.rawValue
                    } label: {
                        Label(mode.title, systemImage: mode.iconName)
                    }
                }
            } label: {
                Image(systemName: currentThemeMode.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.emerald)
                    .padding(6)
            }
            .accessibilityLabel("Appearance Theme Switcher")

            Button(action: completeOnboarding) {
                Text("Skip")
                    .font(.appCallout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var brandHeroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.emerald.opacity(0.18), AppTheme.emeraldLight.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .foregroundColor(AppTheme.emerald)
            }

            VStack(spacing: 4) {
                Text("TeaYield AI")
                    .font(.appLargeTitle)
                    .foregroundColor(.primary)

                Text("PRECISION AGRICULTURE • CEYLON TEA")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(1.2)
            }
        }
    }

    private var carouselSection: some View {
        TabView(selection: $currentSlide) {
            ForEach(0..<slides.count, id: \.self) { index in
                OnboardingSlideCardView(slide: slides[index])
                    .tag(index)
                    .padding(.horizontal, 24)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var pageIndicatorDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                Capsule()
                    .fill(currentSlide == index ? AppTheme.emerald : Color.secondary.opacity(0.25))
                    .frame(width: currentSlide == index ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentSlide)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentSlide + 1) of \(slides.count)")
    }

    private var bottomActionControls: some View {
        VStack(spacing: 12) {
            Button(action: nextSlideOrFinish) {
                HStack(spacing: 8) {
                    Text(currentSlide == slides.count - 1 ? "Get Started" : "Continue")
                        .font(.appHeadline)
                        .foregroundColor(.white)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppTheme.emerald)
                .cornerRadius(AppTheme.radiusMedium)
                .shadow(color: AppTheme.emerald.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            Button(action: completeOnboarding) {
                HStack(spacing: 4) {
                    Text("Already registered?")
                        .font(.appCaption)
                        .foregroundColor(.secondary)

                    Text("Sign In")
                        .font(.appCaption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Navigation Logic

    private func nextSlideOrFinish() {
        HapticFeedback.lightImpact()
        if currentSlide < slides.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentSlide += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func triggerHaptic() {
        HapticFeedback.lightImpact()
    }

    private func completeOnboarding() {
        HapticFeedback.lightImpact()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(.easeInOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
    }
}

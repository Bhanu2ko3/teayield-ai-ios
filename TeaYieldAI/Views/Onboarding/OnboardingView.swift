import SwiftUI

/// Onboarding carousel introducing Zero-IoT satellite yield prediction, Core ML shoot vision, and GA scheduling.
/// Conforms to Figma Screen 01 (Welcome Onboarding View).
struct OnboardingView: View {

    @Binding var hasCompletedOnboarding: Bool
    @State private var currentSlide = 0

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            badge: "SENTINEL-2 & PLANETSCOPE AI",
            title: "Zero-IoT Satellite Yield Prediction & Plucking Optimization",
            description: "Predict daily block yield, detect peak vegetative NDVI (0.82) windows, and automate plucker task allocation across Pedro Estate without physical sensors.",
            pills: [
                PillItem(title: "0.82", subtitle: "Peak NDVI"),
                PillItem(title: "850 kg", subtitle: "Pedro Target"),
                PillItem(title: "88%", subtitle: "Two Leaves")
            ]
        ),
        OnboardingSlide(
            badge: "ON-DEVICE APPLE SILICON NEURAL ENGINE",
            title: "Real-Time 60fps Shoot Maturity Quality Inspection",
            description: "Evaluate the fine-to-coarse leaf ratio directly on your iPhone camera. Guarantees 85% Two Leaves and a Bud auction export benchmarks 100% offline.",
            pills: [
                PillItem(title: "60 FPS", subtitle: "Live Scanner"),
                PillItem(title: "Zero Latency", subtitle: "Neural Engine"),
                PillItem(title: "Grade A", subtitle: "Fine Shoot")
            ]
        ),
        OnboardingSlide(
            badge: "DEAP GENETIC ALGORITHM ENGINE",
            title: "Conflict-Free Workforce Scheduling & Factory Protection",
            description: "Translate complex yield forecasts into balanced 6-day plucking rosters, preventing mountain labor mismatch and factory withering trough overloads.",
            pills: [
                PillItem(title: "3,000 kg", subtitle: "Intake Cap"),
                PillItem(title: "6-Day", subtitle: "Rest Cycle"),
                PillItem(title: "Optimal", subtitle: "Labor Match")
            ]
        )
    ]

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
        }
    }

    // MARK: - Subviews

    private var topHeaderBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.emerald)
                    .frame(width: 8, height: 8)

                Text("PEDRO ESTATE V2.4")
                    .font(.appBadge)
                    .foregroundColor(.secondary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(AppTheme.radiusPill)

            Spacer()

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
                slideCard(slides[index])
                    .tag(index)
                    .padding(.horizontal, 24)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private func slideCard(_ slide: OnboardingSlide) -> some View {
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

    private var pageIndicatorDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                Capsule()
                    .fill(currentSlide == index ? AppTheme.emerald : Color.secondary.opacity(0.25))
                    .frame(width: currentSlide == index ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentSlide)
            }
        }
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
        triggerHaptic()
        if currentSlide < slides.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentSlide += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        triggerHaptic()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(.easeInOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Slide Models

private struct OnboardingSlide {
    let badge: String
    let title: String
    let description: String
    let pills: [PillItem]
}

private struct PillItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

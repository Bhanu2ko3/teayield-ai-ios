import Foundation

/// Slide item for welcome onboarding carousel detailing precision agriculture modules.
struct OnboardingSlide: Identifiable {
    let id = UUID()
    let badge: String
    let title: String
    let description: String
    let pills: [OnboardingPill]

    static let defaultSlides: [OnboardingSlide] = [
        OnboardingSlide(
            badge: "SENTINEL-2 & PLANETSCOPE AI",
            title: "Zero-IoT Satellite Yield Prediction & Plucking Optimization",
            description: "Predict daily block yield, detect peak vegetative NDVI (0.82) windows, and automate plucker task allocation across tea field blocks without physical sensors.",
            pills: [
                OnboardingPill(title: "0.82", subtitle: "Peak NDVI"),
                OnboardingPill(title: "850 kg", subtitle: "Daily Target"),
                OnboardingPill(title: "88%", subtitle: "Two Leaves")
            ]
        ),
        OnboardingSlide(
            badge: "ON-DEVICE APPLE SILICON NEURAL ENGINE",
            title: "Real-Time 60fps Shoot Maturity Quality Inspection",
            description: "Evaluate the fine-to-coarse leaf ratio directly on your iPhone camera. Guarantees 85% Two Leaves and a Bud auction export benchmarks 100% offline.",
            pills: [
                OnboardingPill(title: "60 FPS", subtitle: "Live Scanner"),
                OnboardingPill(title: "Zero Latency", subtitle: "Neural Engine"),
                OnboardingPill(title: "Grade A", subtitle: "Fine Shoot")
            ]
        ),
        OnboardingSlide(
            badge: "DEAP GENETIC ALGORITHM ENGINE",
            title: "Conflict-Free Workforce Scheduling & Factory Protection",
            description: "Translate complex yield forecasts into balanced 6-day plucking rosters, preventing mountain labor mismatch and factory withering trough overloads.",
            pills: [
                OnboardingPill(title: "3,000 kg", subtitle: "Intake Cap"),
                OnboardingPill(title: "6-Day", subtitle: "Rest Cycle"),
                OnboardingPill(title: "Optimal", subtitle: "Labor Match")
            ]
        )
    ]
}

/// Highlight badge metric displayed inside onboarding slides.
struct OnboardingPill: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

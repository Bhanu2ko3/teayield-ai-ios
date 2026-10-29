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
            badge: "SENTINEL-2 SATELLITE TELEMETRY",
            title: "Predict Harvest Yields Ahead of Plucking Rounds",
            description: "Track vegetative canopy vigor across tea blocks using multispectral satellite data to forecast green leaf volume before dispatching plucking gangs.",
            pills: [
                OnboardingPill(title: "0.82", subtitle: "Harvest NDVI"),
                OnboardingPill(title: "7 Days", subtitle: "Yield Forecast"),
                OnboardingPill(title: "Zero-IoT", subtitle: "Remote Sensing")
            ]
        ),
        OnboardingSlide(
            badge: "ON-DEVICE COMPUTER VISION",
            title: "Field-Level Fine Leaf Quality Grading",
            description: "Inspect shoots directly through your camera to verify that harvested tea leaves meet the 85% Two Leaves and a Bud benchmark for Colombo auction standards.",
            pills: [
                OnboardingPill(title: "85%+", subtitle: "Fine Leaf Target"),
                OnboardingPill(title: "Two & Bud", subtitle: "Export Standard"),
                OnboardingPill(title: "100%", subtitle: "Offline Scanner")
            ]
        ),
        OnboardingSlide(
            badge: "GENETIC ROSTER OPTIMIZATION",
            title: "Balanced Plucking Rosters & Factory Intake Control",
            description: "Convert yield forecasts into balanced 6-day plucking rosters that prevent field labor misallocation and protect factory withering troughs from overloading.",
            pills: [
                OnboardingPill(title: "3,000 kg", subtitle: "Withering Cap"),
                OnboardingPill(title: "6-Day", subtitle: "Harvest Cycle"),
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

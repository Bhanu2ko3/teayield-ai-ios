import UIKit

/// Centralized tactile haptic engine providing fluid micro-interactions across user workflows.
enum HapticFeedback {

    /// Triggers a subtle tactile pulse when navigating tabs or selecting filter chips.
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Triggers a light impact pulse when pressing standard buttons or toggling cards.
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Triggers a distinct medium impact pulse when selecting a field block or chart marker.
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Triggers a confirmation haptic pattern upon successful weigh-in save or cloud batch sync.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Triggers a warning pattern when approaching factory capacity thresholds or GPS boundary edges.
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Triggers an error haptic pulse when validation constraints fail or hardware access is denied.
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}

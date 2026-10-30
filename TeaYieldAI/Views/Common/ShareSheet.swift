import SwiftUI
import UIKit

/// Standard UIKit UIActivityViewController wrapper for SwiftUI.
/// Allows sharing, printing, AirDropping, and saving exported PDF rosters.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No dynamic updates required
    }
}

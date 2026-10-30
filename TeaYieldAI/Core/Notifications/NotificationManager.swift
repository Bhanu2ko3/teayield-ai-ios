import Foundation
import UserNotifications

/// Coordinates on-device local notifications for shift briefings, geofence arrivals, and sync alerts.
@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - UNUserNotificationCenterDelegate (Foreground Presentation)

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner, sound, and badge even while app is active in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Requests user authorization for notification alerts, sounds, and badges.
    func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            self.isAuthorized = granted
            return granted
        } catch {
            self.isAuthorized = false
            return false
        }
    }

    /// Queries the current system notification authorization status.
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        self.isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Dispatches a confirmation alert when offline harvest weighing logs are synced to the cloud.
    func sendSyncConfirmation(recordsCount: Int) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cloud Synchronization Completed"
        content.body = "Successfully uploaded \(recordsCount) offline harvest weighing log\(recordsCount == 1 ? "" : "s") to the estate database."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "sync.confirmation.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Dispatches a geofence arrival reminder when a supervisor enters an assigned plucking field.
    func sendGeofenceArrivalAlert(fieldName: String) {
        Task {
            if !isAuthorized {
                _ = await requestAuthorization()
            }

            let content = UNMutableNotificationContent()
            content.title = "Harvest Field Boundary Reached"
            content.body = "You have entered \(fieldName). Spatial geofence active — tap to record green leaf harvest."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(
                identifier: "geofence.arrival.\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}

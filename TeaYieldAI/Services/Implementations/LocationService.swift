import Foundation
import CoreLocation

// MARK: - Notification Center Event Identifiers

extension Notification.Name {
    static let teaFieldGeofenceEntered = Notification.Name("teaFieldGeofenceEntered")
    static let teaFieldGeofenceExited = Notification.Name("teaFieldGeofenceExited")
}

/// Production implementation of hardware GPS geofencing and proximity monitoring.
/// Utilizes low-power CLCircularRegion boundaries to prevent battery drain in remote mountain estates.
final class LocationService: NSObject, LocationServiceProtocol {

    private let locationManager = CLLocationManager()
    private(set) var monitoredFields: [TeaField] = []

    private(set) var currentLocation: CLLocation?
    private(set) var activeGeofencedField: TeaField?
    private(set) var isMonitoringGeofences: Bool = false

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    override init() {
        super.init()
        locationManager.delegate = self
        // Hundred meters accuracy minimizes mountain battery drain while providing reliable field entry
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50.0
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    // MARK: - Authorization

    func requestAuthorization() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Geofence Lifecycle Management

    func startMonitoringFields(_ fields: [TeaField]) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            return
        }

        stopMonitoring()
        self.monitoredFields = fields
        self.isMonitoringGeofences = true

        // Register low-power circular geofences (capped at 20 by Apple CoreLocation guidelines)
        for field in fields.prefix(20) {
            let region = CLCircularRegion(
                center: field.centroidCoordinate,
                radius: 180.0, // 180-meter field perimeter radius
                identifier: field.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true

            locationManager.startMonitoring(for: region)
        }

        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        locationManager.stopUpdatingLocation()
        self.isMonitoringGeofences = false
        self.activeGeofencedField = nil
    }

    // MARK: - Simulation for Viva Defense & Simulator Testing

    func simulateArrival(at field: TeaField) {
        self.activeGeofencedField = field

        // Trigger local notification via system UserNotifications
        Task { @MainActor in
            NotificationManager.shared.sendGeofenceArrivalAlert(fieldName: field.name)
        }

        // Post global event for UI reactive updates
        NotificationCenter.default.post(
            name: .teaFieldGeofenceEntered,
            object: field
        )
    }

    func simulateExit() {
        guard let field = activeGeofencedField else { return }
        self.activeGeofencedField = nil

        NotificationCenter.default.post(
            name: .teaFieldGeofenceExited,
            object: field
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if !monitoredFields.isEmpty {
                startMonitoringFields(monitoredFields)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion,
              let matchedField = monitoredFields.first(where: { $0.id.uuidString == circularRegion.identifier }) else {
            return
        }

        self.activeGeofencedField = matchedField

        // Dispatches on-device local alert without remote server dependency
        Task { @MainActor in
            NotificationManager.shared.sendGeofenceArrivalAlert(fieldName: matchedField.name)
        }

        NotificationCenter.default.post(
            name: .teaFieldGeofenceEntered,
            object: matchedField
        )
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion,
              let matchedField = monitoredFields.first(where: { $0.id.uuidString == circularRegion.identifier }) else {
            return
        }

        if activeGeofencedField?.id == matchedField.id {
            self.activeGeofencedField = nil
        }

        NotificationCenter.default.post(
            name: .teaFieldGeofenceExited,
            object: matchedField
        )
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // Handled silently to avoid UI disruption during intermittent mountain GPS reception
    }
}

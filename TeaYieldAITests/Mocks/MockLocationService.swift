import Foundation
import CoreLocation
@testable import TeaYieldAI

/// Test double simulating CoreLocation hardware and geofence events.
final class MockLocationService: LocationServiceProtocol {

    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var activeGeofencedField: TeaField?
    var isMonitoringGeofences: Bool = false
    var monitoredFields: [TeaField] = []

    private(set) var requestAuthorizationCallCount: Int = 0
    private(set) var startMonitoringCallCount: Int = 0
    private(set) var stopMonitoringCallCount: Int = 0
    private(set) var simulateArrivalCallCount: Int = 0
    private(set) var simulateExitCallCount: Int = 0

    func requestAuthorization() {
        requestAuthorizationCallCount += 1
    }

    func startMonitoringFields(_ fields: [TeaField]) {
        startMonitoringCallCount += 1
        monitoredFields = fields
        isMonitoringGeofences = true
    }

    func stopMonitoring() {
        stopMonitoringCallCount += 1
        isMonitoringGeofences = false
        activeGeofencedField = nil
    }

    func simulateArrival(at field: TeaField) {
        simulateArrivalCallCount += 1
        activeGeofencedField = field
        NotificationCenter.default.post(
            name: .teaFieldGeofenceEntered,
            object: field
        )
    }

    func simulateExit() {
        simulateExitCallCount += 1
        let previousField = activeGeofencedField
        activeGeofencedField = nil
        NotificationCenter.default.post(
            name: .teaFieldGeofenceExited,
            object: previousField
        )
    }
}

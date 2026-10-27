import Foundation
import CoreLocation

/// Defines the contract for background GPS location monitoring and circular geofencing.
protocol LocationServiceProtocol: AnyObject {

    /// Current user location coordinate if authorized.
    var currentLocation: CLLocation? { get }

    /// System CoreLocation authorization state.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Active tea field currently enclosing the supervisor's physical device position.
    var activeGeofencedField: TeaField? { get }

    /// Indicates whether active circular geofence monitoring is active.
    var isMonitoringGeofences: Bool { get }

    /// List of tea fields currently tracked with low-power circular geofences.
    var monitoredFields: [TeaField] { get }

    /// Prompts the user for location services authorization.
    func requestAuthorization()

    /// Registers low-power CLCircularRegion geofences centered on assigned harvest-ready fields.
    func startMonitoringFields(_ fields: [TeaField])

    /// Halts active geofence monitoring to preserve battery.
    func stopMonitoring()

    /// Simulates arrival at a specified field for Viva defense and Simulator testing.
    func simulateArrival(at field: TeaField)

    /// Simulates exiting a geofence boundary.
    func simulateExit()
}

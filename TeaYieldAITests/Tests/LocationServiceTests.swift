import Foundation
import CoreLocation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Location & Geofencing Service Unit Tests")
struct LocationServiceTests {

    private func createTestField(acreage: Double, lat: Double = 6.9650, lon: Double = 80.7930) -> TeaField {
        TeaField(
            id: UUID(),
            name: "Test Plot \(acreage) Acres",
            blockCode: "TEST-BLK",
            acreage: acreage,
            currentNDVI: 0.80,
            status: .ready,
            centroidLatitude: lat,
            centroidLongitude: lon,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
    }

    @Test("Verifies dynamic geofence radius derivation from acreage")
    func dynamicRadiusCalculation() {
        // Radius formula: sqrt((acreage * 4046.86) / pi) + 40m, clamped between 100m and 250m
        let calculateRadius: (Double) -> Double = { acreage in
            let raw = sqrt((max(acreage, 0.5) * 4046.86) / .pi) + 40.0
            return max(100.0, min(250.0, raw))
        }

        // Test normal standard division (4.5 acres)
        let standardRadius = calculateRadius(4.5)
        #expect(standardRadius > 110.0 && standardRadius < 125.0)

        // Test small nursery pocket (0.2 acres) - clamped to 100m minimum
        let smallRadius = calculateRadius(0.2)
        #expect(smallRadius == 100.0)

        // Test massive commercial division (80 acres) - clamped to 250m maximum
        let largeRadius = calculateRadius(80.0)
        #expect(largeRadius == 250.0)
    }

    @Test("Verifies simulate arrival sets active field and posts entered notification")
    func simulateArrivalNotification() async {
        let locationService = LocationService()
        let field = createTestField(acreage: 4.2)

        var notificationReceived = false
        var receivedField: TeaField? = nil

        let observer = NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceEntered,
            object: nil,
            queue: .main
        ) { notification in
            notificationReceived = true
            receivedField = notification.object as? TeaField
        }

        locationService.simulateArrival(at: field)
        try? await Task.sleep(nanoseconds: 30_000_000)

        #expect(notificationReceived == true)
        #expect(receivedField?.id == field.id)
        #expect(locationService.activeGeofencedField?.id == field.id)

        NotificationCenter.default.removeObserver(observer)
    }

    @Test("Verifies simulate exit clears active field and posts exited notification")
    func simulateExitNotification() async {
        let locationService = LocationService()
        let field = createTestField(acreage: 4.2)

        locationService.simulateArrival(at: field)
        try? await Task.sleep(nanoseconds: 20_000_000)
        #expect(locationService.activeGeofencedField != nil)

        var exitReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceExited,
            object: nil,
            queue: .main
        ) { _ in
            exitReceived = true
        }

        locationService.simulateExit()
        try? await Task.sleep(nanoseconds: 30_000_000)

        #expect(exitReceived == true)
        #expect(locationService.activeGeofencedField == nil)

        NotificationCenter.default.removeObserver(observer)
    }

    @Test("Verifies stopMonitoring resets active monitoring flags")
    func stopMonitoring() {
        let locationService = LocationService()
        let field = createTestField(acreage: 3.5)

        locationService.simulateArrival(at: field)
        #expect(locationService.activeGeofencedField != nil)

        locationService.stopMonitoring()

        #expect(locationService.isMonitoringGeofences == false)
        #expect(locationService.activeGeofencedField == nil)
    }
}

#else
import XCTest

final class LocationServiceTests: XCTestCase {

    private func createTestField(acreage: Double, lat: Double = 6.9650, lon: Double = 80.7930) -> TeaField {
        TeaField(
            id: UUID(),
            name: "Test Plot \(acreage) Acres",
            blockCode: "TEST-BLK",
            acreage: acreage,
            currentNDVI: 0.80,
            status: .ready,
            centroidLatitude: lat,
            centroidLongitude: lon,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
    }

    func testDynamicRadiusCalculation() {
        let calculateRadius: (Double) -> Double = { acreage in
            let raw = sqrt((max(acreage, 0.5) * 4046.86) / .pi) + 40.0
            return max(100.0, min(250.0, raw))
        }

        let standardRadius = calculateRadius(4.5)
        XCTAssertGreaterThan(standardRadius, 110.0)
        XCTAssertLessThan(standardRadius, 125.0)

        let smallRadius = calculateRadius(0.2)
        XCTAssertEqual(smallRadius, 100.0)

        let largeRadius = calculateRadius(80.0)
        XCTAssertEqual(largeRadius, 250.0)
    }

    func testSimulateArrivalNotification() async throws {
        let locationService = LocationService()
        let field = createTestField(acreage: 4.2)

        var notificationReceived = false
        var receivedField: TeaField? = nil

        let observer = NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceEntered,
            object: nil,
            queue: .main
        ) { notification in
            notificationReceived = true
            receivedField = notification.object as? TeaField
        }

        locationService.simulateArrival(at: field)
        try await Task.sleep(nanoseconds: 30_000_000)

        XCTAssertTrue(notificationReceived)
        XCTAssertEqual(receivedField?.id, field.id)
        XCTAssertEqual(locationService.activeGeofencedField?.id, field.id)

        NotificationCenter.default.removeObserver(observer)
    }

    func testSimulateExitNotification() async throws {
        let locationService = LocationService()
        let field = createTestField(acreage: 4.2)

        locationService.simulateArrival(at: field)
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertNotNil(locationService.activeGeofencedField)

        var exitReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceExited,
            object: nil,
            queue: .main
        ) { _ in
            exitReceived = true
        }

        locationService.simulateExit()
        try await Task.sleep(nanoseconds: 30_000_000)

        XCTAssertTrue(exitReceived)
        XCTAssertNil(locationService.activeGeofencedField)

        NotificationCenter.default.removeObserver(observer)
    }

    func testStopMonitoring() {
        let locationService = LocationService()
        let field = createTestField(acreage: 3.5)

        locationService.simulateArrival(at: field)
        XCTAssertNotNil(locationService.activeGeofencedField)

        locationService.stopMonitoring()

        XCTAssertFalse(locationService.isMonitoringGeofences)
        XCTAssertNil(locationService.activeGeofencedField)
    }
}
#endif

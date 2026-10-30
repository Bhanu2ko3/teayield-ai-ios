import Foundation
import MapKit
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Field Map ViewModel Unit Tests")
@MainActor
struct FieldMapViewModelTests {

    private func createSampleFields() -> [TeaField] {
        return [
            TeaField(
                id: UUID(),
                name: "Pedro Upper Division",
                blockCode: "PED-BLK-A",
                acreage: 4.5,
                currentNDVI: 0.82,
                status: .ready,
                centroidLatitude: 6.9650,
                centroidLongitude: 80.7930,
                polygonCoordinates: [
                    CoordinatePair(latitude: 6.966, longitude: 80.792),
                    CoordinatePair(latitude: 6.966, longitude: 80.794),
                    CoordinatePair(latitude: 6.964, longitude: 80.794),
                    CoordinatePair(latitude: 6.964, longitude: 80.792)
                ],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 12)
            ),
            TeaField(
                id: UUID(),
                name: "Lovers Leap Plateau",
                blockCode: "PED-BLK-B",
                acreage: 3.8,
                currentNDVI: 0.61,
                status: .growing,
                centroidLatitude: 6.9630,
                centroidLongitude: 80.7950,
                polygonCoordinates: [],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 5)
            ),
            TeaField(
                id: UUID(),
                name: "Mahagastotte Slopes",
                blockCode: "PED-BLK-C",
                acreage: 5.2,
                currentNDVI: 0.38,
                status: .resting,
                centroidLatitude: 6.9610,
                centroidLongitude: 80.7910,
                polygonCoordinates: [],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 25)
            )
        ]
    }

    @Test("Verifies initial state of the spatial map view model")
    func initialState() {
        let repo = MockFieldRepository()
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        #expect(viewModel.fields.isEmpty)
        #expect(viewModel.selectedField == nil)
        #expect(viewModel.filterStatus == nil)
        #expect(viewModel.mapType == .hybrid)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showingFieldDetail == false)
        #expect(viewModel.activeGeofencedField == nil)
    }

    @Test("Verifies loading fields from repository updates camera region")
    func loadFieldsFromRepository() async {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        #expect(viewModel.fields.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.cameraRegion.center.latitude == sampleFields.first?.centroidLatitude)
    }

    @Test("Verifies status filtering narrows displayed fields")
    func statusFiltering() async {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        #expect(viewModel.filteredFields.count == 3)

        viewModel.filterStatus = .ready
        #expect(viewModel.filteredFields.count == 1)
        #expect(viewModel.filteredFields.first?.status == .ready)

        viewModel.filterStatus = .growing
        #expect(viewModel.filteredFields.count == 1)
        #expect(viewModel.filteredFields.first?.status == .growing)

        viewModel.filterStatus = .resting
        #expect(viewModel.filteredFields.count == 1)
        #expect(viewModel.filteredFields.first?.status == .resting)

        viewModel.filterStatus = nil
        #expect(viewModel.filteredFields.count == 3)
    }

    @Test("Verifies status count aggregation metrics")
    func countMetrics() async {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        #expect(viewModel.harvestReadyCount == 1)
        #expect(viewModel.growingCount == 1)
        #expect(viewModel.restingCount == 1)
    }

    @Test("Verifies selecting a field focuses camera and shows detail sheet")
    func selectFieldFocusesCamera() async {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()
        let targetField = sampleFields[1]

        viewModel.selectField(targetField)

        #expect(viewModel.selectedField?.id == targetField.id)
        #expect(viewModel.showingFieldDetail == true)
        #expect(viewModel.cameraRegion.center.latitude == targetField.centroidLatitude)
        #expect(viewModel.cameraRegion.center.longitude == targetField.centroidLongitude)
    }

    @Test("Verifies geofence arrival notification updates activeGeofencedField")
    func geofenceArrivalNotification() async {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()
        let fieldToEnter = sampleFields[0]

        // Post geofence entered event
        NotificationCenter.default.post(name: .teaFieldGeofenceEntered, object: fieldToEnter)
        try? await Task.sleep(nanoseconds: 20_000_000)

        #expect(viewModel.activeGeofencedField?.id == fieldToEnter.id)

        // Post geofence exited event
        NotificationCenter.default.post(name: .teaFieldGeofenceExited, object: fieldToEnter)
        try? await Task.sleep(nanoseconds: 20_000_000)

        #expect(viewModel.activeGeofencedField == nil)
    }
}

#else
import XCTest

@MainActor
final class FieldMapViewModelTests: XCTestCase {

    private func createSampleFields() -> [TeaField] {
        return [
            TeaField(
                id: UUID(),
                name: "Pedro Upper Division",
                blockCode: "PED-BLK-A",
                acreage: 4.5,
                currentNDVI: 0.82,
                status: .ready,
                centroidLatitude: 6.9650,
                centroidLongitude: 80.7930,
                polygonCoordinates: [
                    CoordinatePair(latitude: 6.966, longitude: 80.792),
                    CoordinatePair(latitude: 6.966, longitude: 80.794),
                    CoordinatePair(latitude: 6.964, longitude: 80.794),
                    CoordinatePair(latitude: 6.964, longitude: 80.792)
                ],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 12)
            ),
            TeaField(
                id: UUID(),
                name: "Lovers Leap Plateau",
                blockCode: "PED-BLK-B",
                acreage: 3.8,
                currentNDVI: 0.61,
                status: .growing,
                centroidLatitude: 6.9630,
                centroidLongitude: 80.7950,
                polygonCoordinates: [],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 5)
            ),
            TeaField(
                id: UUID(),
                name: "Mahagastotte Slopes",
                blockCode: "PED-BLK-C",
                acreage: 5.2,
                currentNDVI: 0.38,
                status: .resting,
                centroidLatitude: 6.9610,
                centroidLongitude: 80.7910,
                polygonCoordinates: [],
                lastHarvestedDate: Date().addingTimeInterval(-86400 * 25)
            )
        ]
    }

    func testInitialState() {
        let repo = MockFieldRepository()
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        XCTAssertTrue(viewModel.fields.isEmpty)
        XCTAssertNil(viewModel.selectedField)
        XCTAssertNil(viewModel.filterStatus)
        XCTAssertEqual(viewModel.mapType, .hybrid)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showingFieldDetail)
        XCTAssertNil(viewModel.activeGeofencedField)
    }

    func testLoadFieldsFromRepository() async throws {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        XCTAssertEqual(viewModel.fields.count, 3)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.cameraRegion.center.latitude, sampleFields.first?.centroidLatitude)
    }

    func testStatusFiltering() async throws {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        XCTAssertEqual(viewModel.filteredFields.count, 3)

        viewModel.filterStatus = .ready
        XCTAssertEqual(viewModel.filteredFields.count, 1)
        XCTAssertEqual(viewModel.filteredFields.first?.status, .ready)

        viewModel.filterStatus = .growing
        XCTAssertEqual(viewModel.filteredFields.count, 1)
        XCTAssertEqual(viewModel.filteredFields.first?.status, .growing)

        viewModel.filterStatus = .resting
        XCTAssertEqual(viewModel.filteredFields.count, 1)
        XCTAssertEqual(viewModel.filteredFields.first?.status, .resting)

        viewModel.filterStatus = nil
        XCTAssertEqual(viewModel.filteredFields.count, 3)
    }

    func testCountMetrics() async throws {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()

        XCTAssertEqual(viewModel.harvestReadyCount, 1)
        XCTAssertEqual(viewModel.growingCount, 1)
        XCTAssertEqual(viewModel.restingCount, 1)
    }

    func testSelectFieldFocusesCamera() async throws {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()
        let targetField = sampleFields[1]

        viewModel.selectField(targetField)

        XCTAssertEqual(viewModel.selectedField?.id, targetField.id)
        XCTAssertTrue(viewModel.showingFieldDetail)
        XCTAssertEqual(viewModel.cameraRegion.center.latitude, targetField.centroidLatitude)
        XCTAssertEqual(viewModel.cameraRegion.center.longitude, targetField.centroidLongitude)
    }

    func testGeofenceArrivalNotification() async throws {
        let sampleFields = createSampleFields()
        let repo = MockFieldRepository(initialFields: sampleFields)
        let location = MockLocationService()
        let viewModel = FieldMapViewModel(fieldRepository: repo, locationService: location)

        await viewModel.loadFields()
        let fieldToEnter = sampleFields[0]

        NotificationCenter.default.post(name: .teaFieldGeofenceEntered, object: fieldToEnter)
        try await Task.sleep(nanoseconds: 20_000_000)

        XCTAssertEqual(viewModel.activeGeofencedField?.id, fieldToEnter.id)

        NotificationCenter.default.post(name: .teaFieldGeofenceExited, object: fieldToEnter)
        try await Task.sleep(nanoseconds: 20_000_000)

        XCTAssertNil(viewModel.activeGeofencedField)
    }
}
#endif

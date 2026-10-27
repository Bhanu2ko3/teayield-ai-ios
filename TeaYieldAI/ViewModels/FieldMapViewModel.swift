import Foundation
import MapKit
import Combine

/// Drives spatial GIS visualization, polygon rendering, and field selection.
/// Strictly conforms to Xcode 14.3.1 / iOS 16.4 baseline with ObservableObject and @MainActor.
@MainActor
final class FieldMapViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var fields: [TeaField] = []
    @Published var selectedField: TeaField? = nil
    @Published var filterStatus: FieldReadinessStatus? = nil
    @Published var mapType: MKMapType = .hybrid
    @Published var isLoading: Bool = false
    @Published var showingFieldDetail: Bool = false
    @Published var errorMessage: String? = nil

    @Published var cameraRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: MockData.nuwaraEliyaEstateCentroid,
        span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
    )

    // MARK: - Dependencies

    private let fieldRepository: FieldRepositoryProtocol

    // MARK: - Computed Properties

    var filteredFields: [TeaField] {
        guard let filter = filterStatus else { return fields }
        return fields.filter { $0.status == filter }
    }

    var harvestReadyCount: Int {
        fields.filter { $0.status == .ready }.count
    }

    var growingCount: Int {
        fields.filter { $0.status == .growing }.count
    }

    var restingCount: Int {
        fields.filter { $0.status == .resting }.count
    }

    // MARK: - Initialization

    init(fieldRepository: FieldRepositoryProtocol) {
        self.fieldRepository = fieldRepository
    }

    // MARK: - Field Data Loading

    func loadFields() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await fieldRepository.fetchCachedFields()
            if fetched.isEmpty {
                // Populate initial Pedro Estate mock fields if Core Data is unseeded
                let initial = [MockData.fieldBlockA, MockData.fieldBlockB, MockData.fieldBlockC]
                for field in initial {
                    try? await fieldRepository.saveField(field)
                }
                self.fields = initial
            } else {
                self.fields = fetched
            }

            // Center camera bounding box around estate centroid
            if let first = fields.first {
                self.cameraRegion = MKCoordinateRegion(
                    center: first.centroidCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.020, longitudeDelta: 0.020)
                )
            }
        } catch {
            self.errorMessage = "Failed to load cached field divisions: \(error.localizedDescription)"
            self.fields = [MockData.fieldBlockA, MockData.fieldBlockB, MockData.fieldBlockC]
        }

        isLoading = false
    }

    // MARK: - User Interactions

    func selectField(_ field: TeaField) {
        self.selectedField = field
        self.showingFieldDetail = true
        focusOnField(field)
    }

    func focusOnField(_ field: TeaField) {
        self.cameraRegion = MKCoordinateRegion(
            center: field.centroidCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
    }

    func resetCameraToEstate() {
        if let first = fields.first {
            self.cameraRegion = MKCoordinateRegion(
                center: first.centroidCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.022, longitudeDelta: 0.022)
            )
        }
    }

    func toggleMapType() {
        mapType = (mapType == .hybrid) ? .standard : .hybrid
    }

    func setFilter(_ status: FieldReadinessStatus?) {
        self.filterStatus = status
    }
}

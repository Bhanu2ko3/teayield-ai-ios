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

    @Published var activeGeofencedField: TeaField? = nil

    @Published var cameraRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9642, longitude: 80.7932),
        span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
    )

    // MARK: - Dependencies

    private let fieldRepository: FieldRepositoryProtocol
    let locationService: LocationServiceProtocol
    private let apiService: APIServiceProtocol?
    private let authService: AuthServiceProtocol?

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

    init(
        fieldRepository: FieldRepositoryProtocol,
        locationService: LocationServiceProtocol = LocationService(),
        apiService: APIServiceProtocol? = nil,
        authService: AuthServiceProtocol? = nil
    ) {
        self.fieldRepository = fieldRepository
        self.locationService = locationService
        self.apiService = apiService
        self.authService = authService
        setupGeofenceObservers()
    }

    private func setupGeofenceObservers() {
        NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceEntered,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                self?.activeGeofencedField = notification.object as? TeaField
            }
        }

        NotificationCenter.default.addObserver(
            forName: .teaFieldGeofenceExited,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.activeGeofencedField = nil
            }
        }
    }

    /// Simulates arriving at a specific field boundary for live demonstration during the Viva exam.
    func simulateGeofenceArrival(at field: TeaField) {
        locationService.simulateArrival(at: field)
    }

    // MARK: - Field Data Loading

    func loadFields() async {
        isLoading = true
        errorMessage = nil

        do {
            var fetched: [TeaField] = []

            // If online and estate is bound, fetch fresh remote field polygon boundaries
            if let api = apiService,
               let estateId = authService?.currentUser?.estateId {
                if let dtos = try? await api.fetchFields(estateId: estateId), !dtos.isEmpty {
                    let domainFields = dtos.map { $0.toDomain() }
                    try? await fieldRepository.saveFields(domainFields)
                    fetched = domainFields
                }
            }

            // Fallback to local offline Core Data persistence
            if fetched.isEmpty {
                fetched = try await fieldRepository.fetchCachedFields()
            }

            self.fields = fetched

            // Center camera bounding box around estate centroid if fields exist
            if let first = fields.first {
                self.cameraRegion = MKCoordinateRegion(
                    center: first.centroidCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.020, longitudeDelta: 0.020)
                )
            }
        } catch {
            self.errorMessage = "Failed to load field divisions: \(error.localizedDescription)"
            self.fields = (try? await fieldRepository.fetchCachedFields()) ?? []
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

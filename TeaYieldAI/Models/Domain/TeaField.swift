import Foundation
import CoreLocation

/// Geographic coordinate pair for field boundary rendering.
struct CoordinatePair: Hashable, Codable {
    let latitude: Double
    let longitude: Double
    
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Harvest readiness state based on satellite NDVI vegetation index.
enum FieldReadinessStatus: String, CaseIterable, Codable {
    case ready = "READY"
    case growing = "GROWING"
    case resting = "RESTING"
    
    var displayName: String {
        switch self {
        case .ready: return "Harvest Ready"
        case .growing: return "Growing Phase"
        case .resting: return "Rest Period"
        }
    }
}

/// Core domain model representing a tea field block.
struct TeaField: Identifiable, Hashable, Codable {
    let id: UUID
    let estateId: UUID
    let name: String
    let blockCode: String
    let acreage: Double
    let currentNDVI: Double
    let status: FieldReadinessStatus
    let centroidLatitude: Double
    let centroidLongitude: Double
    let polygonCoordinates: [CoordinatePair]
    let lastHarvestedDate: Date?
    
    // MARK: - Computed Properties
    
    var centroidCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centroidLatitude, longitude: centroidLongitude)
    }
    
    var formattedAcreage: String {
        String(format: "%.2f Ac", acreage)
    }
    
    var formattedNDVI: String {
        String(format: "%.3f", currentNDVI)
    }
    
    var isHarvestReady: Bool {
        status == .ready
    }
}

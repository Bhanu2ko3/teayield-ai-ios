import Foundation
import CoreLocation

/// Represents a field weigh-in record captured by a field supervisor.
struct HarvestRecord: Identifiable, Hashable, Codable {
    /// Client-side UUID for store-and-forward offline synchronization.
    let id: UUID
    let fieldId: UUID
    let pluckerId: String
    let pluckerName: String
    let grossWeightKg: Double
    let tareWeightKg: Double
    let netWeightKg: Double
    let fineLeafRatio: Double
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    var isSynced: Bool
    
    // MARK: - Computed Properties
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Checks if the batch reaches the 85% fine leaf export threshold.
    var meetsExportQuality: Bool {
        fineLeafRatio >= AppConfiguration.fineLeafTargetRatio
    }
    
    var formattedNetWeight: String {
        String(format: "%.2f kg", netWeightKg)
    }
    
    var formattedFineLeafPercentage: String {
        String(format: "%.1f%%", fineLeafRatio * 100.0)
    }
}

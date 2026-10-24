import Foundation
import CoreLocation

/// Daily plucking task assigned to a field block.
struct PluckingTask: Identifiable, Hashable, Codable {
    let id: UUID
    let fieldId: UUID
    let fieldName: String
    let blockCode: String
    let assignedPluckersCount: Int
    let targetWeightKg: Double
    var harvestedWeightKg: Double
    let shiftDate: Date
    var isCompleted: Bool
    let centroidLatitude: Double
    let centroidLongitude: Double
    
    // MARK: - Computed Properties
    
    var centroidCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: centroidLatitude, longitude: centroidLongitude)
    }
    
    /// Progress ratio toward reaching the target weight.
    var progressRatio: Double {
        guard targetWeightKg > 0 else { return 0.0 }
        return min(max(harvestedWeightKg / targetWeightKg, 0.0), 1.0)
    }
    
    /// Remaining leaf weight needed for the target.
    var remainingWeightKg: Double {
        max(targetWeightKg - harvestedWeightKg, 0.0)
    }
    
    var formattedTargetWeight: String {
        String(format: "%.1f kg", targetWeightKg)
    }
    
    var formattedHarvestedWeight: String {
        String(format: "%.1f kg", harvestedWeightKg)
    }
}

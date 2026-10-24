import Foundation

/// Field assignment item in the supervisor daily task briefing.
struct DailySupervisorTaskItemDTO: Codable {
    let fieldId: UUID
    let fieldName: String
    let assignedPluckers: Int
    let targetHarvestKg: Double
    let boundaryGeojson: GeoJSONPolygonDTO
    
    enum CodingKeys: String, CodingKey {
        case fieldId = "field_id"
        case fieldName = "field_name"
        case assignedPluckers = "assigned_pluckers"
        case targetHarvestKg = "target_harvest_kg"
        case boundaryGeojson = "boundary_geojson"
    }
    
    /// Maps the task item to a domain model.
    func toDomain(taskId: UUID = UUID(), shiftDate: Date = Date()) -> PluckingTask {
        let coordinates = boundaryGeojson.toCoordinatePairs()
        let avgLat: Double
        let avgLon: Double
        
        if !coordinates.isEmpty {
            avgLat = coordinates.reduce(0.0) { $0 + $1.latitude } / Double(coordinates.count)
            avgLon = coordinates.reduce(0.0) { $0 + $1.longitude } / Double(coordinates.count)
        } else {
            avgLat = 6.9642
            avgLon = 80.7932
        }
        
        let derivedCode: String
        if fieldName.contains("Block") {
            let parts = fieldName.components(separatedBy: "Block")
            let prefix = parts.first?.split(separator: " ").compactMap { $0.first.map(String.init) }.joined() ?? "F"
            let suffix = parts.last?.trimmingCharacters(in: .whitespaces) ?? "1"
            derivedCode = "\(prefix)-BLK-\(suffix)"
        } else {
            derivedCode = fieldName
        }
        
        return PluckingTask(
            id: taskId,
            fieldId: fieldId,
            fieldName: fieldName,
            blockCode: derivedCode,
            assignedPluckersCount: assignedPluckers,
            targetWeightKg: targetHarvestKg,
            harvestedWeightKg: 0.0,
            shiftDate: shiftDate,
            isCompleted: false,
            centroidLatitude: avgLat,
            centroidLongitude: avgLon
        )
    }
}

/// Daily operational briefing received by a field supervisor.
struct DailySupervisorTasksResponseDTO: Codable {
    let dayIndex: Int
    let dayName: String
    let estateId: UUID
    let assignedFields: [DailySupervisorTaskItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case dayIndex = "day_index"
        case dayName = "day_name"
        case estateId = "estate_id"
        case assignedFields = "assigned_fields"
    }
}

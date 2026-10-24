import Foundation

/// GeoJSON Polygon representation for spatial field boundaries.
struct GeoJSONPolygonDTO: Codable {
    let type: String
    let coordinates: [[[Double]]]
    
    /// Converts GeoJSON [longitude, latitude] coordinate rings into domain coordinate pairs.
    func toCoordinatePairs() -> [CoordinatePair] {
        guard let exteriorRing = coordinates.first else { return [] }
        return exteriorRing.compactMap { point in
            guard point.count >= 2 else { return nil }
            // GeoJSON coordinates order is [longitude, latitude]
            return CoordinatePair(latitude: point[1], longitude: point[0])
        }
    }
}

/// Field plot details returned by the fields service.
struct FieldResponseDTO: Codable {
    let id: UUID
    let estateId: UUID
    let name: String
    let areaAcres: Double
    let boundaryGeojson: GeoJSONPolygonDTO
    let centroidLatitude: Double
    let centroidLongitude: Double
    let currentNdvi: Double
    let daysSinceLastHarvest: Int
    let harvestStatus: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case estateId = "estate_id"
        case name
        case areaAcres = "area_acres"
        case boundaryGeojson = "boundary_geojson"
        case centroidLatitude = "centroid_latitude"
        case centroidLongitude = "centroid_longitude"
        case currentNdvi = "current_ndvi"
        case daysSinceLastHarvest = "days_since_last_harvest"
        case harvestStatus = "harvest_status"
        case createdAt = "created_at"
    }
    
    /// Maps the network DTO to a domain entity.
    func toDomain() -> TeaField {
        let status: FieldReadinessStatus
        switch harvestStatus.uppercased() {
        case "READY":
            status = .ready
        case "GROWING":
            status = .growing
        default:
            status = .resting
        }
        
        let lastHarvestDate = Calendar.current.date(
            byAdding: .day,
            value: -daysSinceLastHarvest,
            to: Date()
        )
        
        let derivedCode: String
        if name.contains("Block") {
            let parts = name.components(separatedBy: "Block")
            let prefix = parts.first?.split(separator: " ").compactMap { $0.first.map(String.init) }.joined() ?? "F"
            let suffix = parts.last?.trimmingCharacters(in: .whitespaces) ?? "1"
            derivedCode = "\(prefix)-BLK-\(suffix)"
        } else {
            derivedCode = name
        }
        
        return TeaField(
            id: id,
            estateId: estateId,
            name: name,
            blockCode: derivedCode,
            acreage: areaAcres,
            currentNDVI: currentNdvi,
            status: status,
            centroidLatitude: centroidLatitude,
            centroidLongitude: centroidLongitude,
            polygonCoordinates: boundaryGeojson.toCoordinatePairs(),
            lastHarvestedDate: lastHarvestDate
        )
    }
}

/// Historical satellite NDVI vegetation record.
struct NDVILogResponseDTO: Codable {
    let id: UUID
    let fieldId: UUID
    let weekStartDate: String
    let ndviValue: Double
    let redBandReflectance: Double
    let nirBandReflectance: Double
    let validPixelRatio: Double
    let satelliteSource: String
    let capturedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fieldId = "field_id"
        case weekStartDate = "week_start_date"
        case ndviValue = "ndvi_value"
        case redBandReflectance = "red_band_reflectance"
        case nirBandReflectance = "nir_band_reflectance"
        case validPixelRatio = "valid_pixel_ratio"
        case satelliteSource = "satellite_source"
        case capturedAt = "captured_at"
    }
}

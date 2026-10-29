import Foundation

/// Enterprise tea estate profile returned by the estates service.
struct EstateResponseDTO: Codable {
    let id: UUID
    let name: String
    let district: String
    let elevationMeters: Int
    let totalAreaAcres: Double
    let dailyFactoryCapacityKg: Double
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case district
        case elevationMeters = "elevation_meters"
        case totalAreaAcres = "total_area_acres"
        case dailyFactoryCapacityKg = "daily_factory_capacity_kg"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Request payload for onboarding a new tea estate into the system.
struct EstateOnboardRequestDTO: Codable {
    let name: String
    let district: String?
    let elevationMeters: Int?
    let totalAreaAcres: Double
    let dailyFactoryCapacityKg: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case district
        case elevationMeters = "elevation_meters"
        case totalAreaAcres = "total_area_acres"
        case dailyFactoryCapacityKg = "daily_factory_capacity_kg"
    }
}

/// Request payload for updating estate parameters and factory ceilings.
struct EstateUpdateRequestDTO: Codable {
    let name: String?
    let district: String?
    let elevationMeters: Int?
    let totalAreaAcres: Double?
    let dailyFactoryCapacityKg: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case district
        case elevationMeters = "elevation_meters"
        case totalAreaAcres = "total_area_acres"
        case dailyFactoryCapacityKg = "daily_factory_capacity_kg"
    }
}

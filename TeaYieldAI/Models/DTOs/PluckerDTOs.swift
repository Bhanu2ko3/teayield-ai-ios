import Foundation

/// Network representation of a registered plucker record returned by the backend.
struct PluckerResponseDTO: Codable, Identifiable {
    let id: UUID
    let estateId: UUID
    let pluckerCode: String
    let fullName: String
    let averageDailyRateKg: Double
    let isActive: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case estateId = "estate_id"
        case pluckerCode = "plucker_code"
        case fullName = "full_name"
        case averageDailyRateKg = "average_daily_rate_kg"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Maps the backend DTO into an internal domain entity.
    func toDomain() -> Plucker {
        Plucker(
            id: id,
            estateId: estateId,
            pluckerCode: pluckerCode,
            fullName: fullName,
            averageDailyRateKg: averageDailyRateKg,
            isActive: isActive
        )
    }
}

/// Request payload for registering a new plucker on the estate.
struct PluckerCreateRequestDTO: Codable {
    let estateId: UUID
    let pluckerCode: String
    let fullName: String
    let averageDailyRateKg: Double?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case pluckerCode = "plucker_code"
        case fullName = "full_name"
        case averageDailyRateKg = "average_daily_rate_kg"
        case isActive = "is_active"
    }
}

/// Request payload for updating plucker details or active status.
struct PluckerUpdateRequestDTO: Codable {
    let fullName: String?
    let averageDailyRateKg: Double?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case averageDailyRateKg = "average_daily_rate_kg"
        case isActive = "is_active"
    }
}

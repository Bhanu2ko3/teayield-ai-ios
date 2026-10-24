import Foundation

/// Request payload for user authentication.
struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

/// Server response containing the JWT bearer access token and user metadata.
struct TokenResponseDTO: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let user: UserProfileDTO
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}

/// User profile details returned by the auth service.
struct UserProfileDTO: Codable {
    let id: UUID
    let estateId: UUID?
    let email: String?
    let fullName: String
    let role: String
    let phoneNumber: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case estateId = "estate_id"
        case email
        case fullName = "full_name"
        case role
        case phoneNumber = "phone_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// Converts the network DTO into an internal domain entity.
    func toDomain(employeeId: String = "EMP-001") -> UserProfile {
        let domainRole: UserRole = (role == "estate_manager") ? .estateManager : .fieldSupervisor
        let defaultEstateId = estateId ?? UUID(uuidString: "3b241101-5231-4822-a982-f87c126d4001")!
        
        return UserProfile(
            id: id,
            email: email ?? "",
            fullName: fullName,
            role: domainRole,
            employeeId: employeeId,
            estateId: defaultEstateId
        )
    }
}

import Foundation

/// Request payload for user authentication.
struct LoginRequestDTO: Codable {
    let email: String
    let password: String

    /// Validates basic email structure and minimum password length before making network calls.
    var isValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailPattern = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"
        let hasValidEmail = trimmed.range(of: emailPattern, options: .regularExpression) != nil
        return hasValidEmail && password.count >= 6
    }
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

    init(
        accessToken: String,
        tokenType: String = "bearer",
        expiresIn: Int = 3600,
        user: UserProfileDTO = UserProfileDTO()
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.user = user
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
    let mustChangePassword: Bool?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case estateId = "estate_id"
        case email
        case fullName = "full_name"
        case role
        case phoneNumber = "phone_number"
        case mustChangePassword = "must_change_password"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(
        id: UUID = UUID(),
        estateId: UUID? = nil,
        email: String? = nil,
        fullName: String = "Enterprise User",
        role: String = "estate_manager",
        phoneNumber: String? = nil,
        mustChangePassword: Bool? = false,
        createdAt: String = "2026-01-01T00:00:00Z",
        updatedAt: String = "2026-01-01T00:00:00Z"
    ) {
        self.id = id
        self.estateId = estateId
        self.email = email
        self.fullName = fullName
        self.role = role
        self.phoneNumber = phoneNumber
        self.mustChangePassword = mustChangePassword
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Converts the network DTO into an internal domain entity.
    func toDomain(employeeId: String? = nil) -> UserProfile {
        let domainRole: UserRole = (role == "estate_manager") ? .estateManager : .fieldSupervisor
        let derivedEmployeeId = employeeId ?? "ID-\(id.uuidString.prefix(6).uppercased())"
        
        return UserProfile(
            id: id,
            email: email ?? "",
            fullName: fullName,
            role: domainRole,
            employeeId: derivedEmployeeId,
            estateId: estateId,
            mustChangePassword: mustChangePassword ?? false
        )
    }
}

/// Request payload for estate manager self-service onboarding registration.
struct ManagerSignUpRequestDTO: Codable {
    let fullName: String
    let email: String
    let password: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email
        case password
        case phoneNumber = "phone_number"
    }
}

/// Request payload for estate manager provisioning a subordinate field supervisor.
struct SupervisorInviteRequestDTO: Codable {
    let fullName: String
    let email: String
    let temporaryPassword: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email
        case temporaryPassword = "temporary_password"
        case phoneNumber = "phone_number"
    }
}

/// Request payload for credential rotation.
struct PasswordChangeRequestDTO: Codable {
    let currentPassword: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
}

/// Standard status response for operation acknowledgments.
struct StatusResponseDTO: Codable {
    let status: String
    let message: String
}

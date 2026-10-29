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
    
    /// Converts the network DTO into an internal domain entity.
    func toDomain(employeeId: String? = nil) -> UserProfile {
        let domainRole: UserRole = (role == "estate_manager") ? .estateManager : .fieldSupervisor
        let resolvedEstateId = estateId ?? UUID()
        let derivedEmployeeId = employeeId ?? "ID-\(id.uuidString.prefix(6).uppercased())"
        
        return UserProfile(
            id: id,
            email: email ?? "",
            fullName: fullName,
            role: domainRole,
            employeeId: derivedEmployeeId,
            estateId: resolvedEstateId,
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

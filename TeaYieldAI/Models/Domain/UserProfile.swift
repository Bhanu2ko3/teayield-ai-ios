import Foundation

/// User roles for authorization and screen navigation.
enum UserRole: String, CaseIterable, Codable {
    case estateManager = "estate_manager"
    case fieldSupervisor = "field_supervisor"
    
    var title: String {
        switch self {
        case .estateManager: return "Estate Manager"
        case .fieldSupervisor: return "Field Superintendent"
        }
    }
}

/// Authenticated employee profile stored after login.
struct UserProfile: Identifiable, Hashable, Codable {
    let id: UUID
    let email: String
    let fullName: String
    let role: UserRole
    let employeeId: String
    let phoneNumber: String?
    let estateId: UUID?
    let mustChangePassword: Bool
    
    init(
        id: UUID,
        email: String,
        fullName: String,
        role: UserRole,
        employeeId: String,
        phoneNumber: String? = nil,
        estateId: UUID? = nil,
        mustChangePassword: Bool = false
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.role = role
        self.employeeId = employeeId
        self.phoneNumber = phoneNumber
        self.estateId = estateId
        self.mustChangePassword = mustChangePassword
    }
    
    var isManager: Bool {
        role == .estateManager
    }
    
    var isSupervisor: Bool {
        role == .fieldSupervisor
    }

    /// Indicates whether the user has an active estate bound to their tenant profile.
    var hasOnboardedEstate: Bool {
        estateId != nil
    }

    /// Returns a mutated copy with an updated estate identifier upon successful estate onboarding.
    func withEstateId(_ newEstateId: UUID) -> UserProfile {
        UserProfile(
            id: id,
            email: email,
            fullName: fullName,
            role: role,
            employeeId: employeeId,
            phoneNumber: phoneNumber,
            estateId: newEstateId,
            mustChangePassword: mustChangePassword
        )
    }

    /// Returns a mutated copy after credential rotation succeeds, clearing the password change requirement.
    func withPasswordChanged() -> UserProfile {
        UserProfile(
            id: id,
            email: email,
            fullName: fullName,
            role: role,
            employeeId: employeeId,
            phoneNumber: phoneNumber,
            estateId: estateId,
            mustChangePassword: false
        )
    }
}

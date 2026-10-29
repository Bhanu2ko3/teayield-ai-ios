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
    let estateId: UUID
    let mustChangePassword: Bool
    
    init(
        id: UUID,
        email: String,
        fullName: String,
        role: UserRole,
        employeeId: String,
        estateId: UUID,
        mustChangePassword: Bool = false
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.role = role
        self.employeeId = employeeId
        self.estateId = estateId
        self.mustChangePassword = mustChangePassword
    }
    
    var isManager: Bool {
        role == .estateManager
    }
    
    var isSupervisor: Bool {
        role == .fieldSupervisor
    }
}

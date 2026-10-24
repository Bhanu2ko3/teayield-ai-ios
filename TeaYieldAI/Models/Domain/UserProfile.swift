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
    
    var isManager: Bool {
        role == .estateManager
    }
    
    var isSupervisor: Bool {
        role == .fieldSupervisor
    }
}

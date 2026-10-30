import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Field Supervisor Delegation ViewModel Unit Tests")
@MainActor
struct SupervisorManagementViewModelTests {

    private func createSampleSupervisors() -> [UserProfile] {
        let estateId = UUID()
        return [
            UserProfile(
                id: UUID(),
                email: "kasun.j@pedro.lk",
                fullName: "Kasun Jayawardena",
                role: .fieldSupervisor,
                employeeId: "SUP-001",
                estateId: estateId
            ),
            UserProfile(
                id: UUID(),
                email: "nuwan.p@pedro.lk",
                fullName: "Nuwan Perera",
                role: .fieldSupervisor,
                employeeId: "SUP-002",
                estateId: estateId
            )
        ]
    }

    @Test("Filters supervisor directory by employee ID, full name, or email")
    func testSupervisorDirectoryFiltering() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = SupervisorManagementViewModel(apiService: api, authService: auth)
        viewModel.supervisors = createSampleSupervisors()

        // 1. Empty query returns all
        viewModel.searchText = ""
        #expect(viewModel.filteredSupervisors.count == 2)

        // 2. Search by employee ID
        viewModel.searchText = "SUP-002"
        #expect(viewModel.filteredSupervisors.count == 1)
        #expect(viewModel.filteredSupervisors.first?.fullName == "Nuwan Perera")

        // 3. Search by partial name
        viewModel.searchText = "kasun"
        #expect(viewModel.filteredSupervisors.count == 1)
        #expect(viewModel.filteredSupervisors.first?.employeeId == "SUP-001")

        // 4. Search by email domain
        viewModel.searchText = "nuwan.p"
        #expect(viewModel.filteredSupervisors.count == 1)
    }

    @Test("Loads active estate field supervisors successfully from backend API")
    func testLoadSupervisorsWorkflow() async {
        let estateId = UUID()
        let manager = UserProfile(
            id: UUID(),
            email: "manager@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .estateManager,
            employeeId: "MGR-082",
            estateId: estateId
        )
        let auth = MockAuthService(initialUser: manager)
        let api = MockAPIService()
        api.mockSupervisors = [
            UserProfileDTO(
                id: UUID(),
                email: "sarath.k@pedro.lk",
                fullName: "Sarath Kumara",
                role: "field_supervisor",
                employeeId: "SUP-015",
                estateId: estateId,
                mustChangePassword: true,
                createdAt: "2026-01-01T00:00:00Z",
                updatedAt: "2026-01-01T00:00:00Z"
            )
        ]

        let viewModel = SupervisorManagementViewModel(apiService: api, authService: auth)
        await viewModel.loadSupervisors()

        #expect(viewModel.supervisors.count == 1)
        #expect(viewModel.supervisors.first?.employeeId == "SUP-015")
        #expect(viewModel.supervisors.first?.mustChangePassword == true)
        #expect(viewModel.isLoading == false)
    }

    @Test("Gracefully handles missing estate association without crashing")
    func testMissingEstateSafeHandling() async {
        let managerWithoutEstate = UserProfile(
            id: UUID(),
            email: "newmanager@tea.lk",
            fullName: "New Manager",
            role: .estateManager,
            employeeId: "MGR-999",
            estateId: nil
        )
        let auth = MockAuthService(initialUser: managerWithoutEstate)
        let api = MockAPIService()
        let viewModel = SupervisorManagementViewModel(apiService: api, authService: auth)

        await viewModel.loadSupervisors()

        #expect(viewModel.supervisors.isEmpty)
        #expect(viewModel.isLoading == false)
    }
}

#else
import XCTest

@MainActor
final class SupervisorManagementViewModelTests: XCTestCase {

    func testDirectoryFiltering() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = SupervisorManagementViewModel(apiService: api, authService: auth)
        viewModel.supervisors = [
            UserProfile(
                id: UUID(),
                email: "kasun.j@pedro.lk",
                fullName: "Kasun Jayawardena",
                role: .fieldSupervisor,
                employeeId: "SUP-001",
                estateId: UUID()
            )
        ]

        viewModel.searchText = "kasun"
        XCTAssertEqual(viewModel.filteredSupervisors.count, 1)
    }
}
#endif

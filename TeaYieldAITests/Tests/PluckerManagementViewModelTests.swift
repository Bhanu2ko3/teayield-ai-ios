import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Plucker Workforce Management ViewModel Unit Tests")
@MainActor
struct PluckerManagementViewModelTests {

    private func createSamplePluckers() -> [Plucker] {
        return [
            Plucker(
                id: UUID(),
                estateId: UUID(),
                pluckerCode: "PLK-001",
                fullName: "Sita Kumari",
                isActive: true,
                assignedFieldId: UUID(),
                averageDailyKg: 24.5,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Plucker(
                id: UUID(),
                estateId: UUID(),
                pluckerCode: "PLK-002",
                fullName: "Rani Perera",
                isActive: true,
                assignedFieldId: nil,
                averageDailyKg: 28.0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Plucker(
                id: UUID(),
                estateId: UUID(),
                pluckerCode: "PLK-003",
                fullName: "Kamala Devi",
                isActive: false,
                assignedFieldId: nil,
                averageDailyKg: 18.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }

    @Test("Filters pluckers accurately by full name and plucker identification code")
    func testSearchFiltering() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        viewModel.pluckers = createSamplePluckers()

        // 1. Empty search returns all records
        viewModel.searchText = ""
        #expect(viewModel.filteredPluckers.count == 3)

        // 2. Search by name (case-insensitive)
        viewModel.searchText = "rani"
        #expect(viewModel.filteredPluckers.count == 1)
        #expect(viewModel.filteredPluckers.first?.pluckerCode == "PLK-002")

        // 3. Search by ID code
        viewModel.searchText = "PLK-003"
        #expect(viewModel.filteredPluckers.count == 1)
        #expect(viewModel.filteredPluckers.first?.fullName == "Kamala Devi")

        // 4. Search non-existent query
        viewModel.searchText = "Unknown"
        #expect(viewModel.filteredPluckers.isEmpty)
    }

    @Test("Calculates active workforce count and estate productivity average")
    func testProductivityMetrics() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        viewModel.pluckers = createSamplePluckers()

        // 2 active pluckers out of 3
        #expect(viewModel.activePluckersCount == 2)

        // Active plucker productivity average: (24.5 + 28.0) / 2 = 26.25 kg/day
        #expect(abs(viewModel.averageProductivityRate - 26.25) < 0.01)
    }

    @Test("Handles empty plucker inventory gracefully without division by zero")
    func testEmptyWorkforceMetrics() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        viewModel.pluckers = []

        #expect(viewModel.activePluckersCount == 0)
        #expect(viewModel.averageProductivityRate == 0.0)
    }

    @Test("Fetches active estate plucker directory from backend API")
    func testFetchPluckersWorkflow() async {
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
        api.mockPluckers = [
            PluckerResponseDTO(
                id: UUID(),
                estateId: estateId,
                pluckerCode: "PLK-088",
                fullName: "Leela Menike",
                isActive: true,
                assignedFieldId: nil,
                averageDailyKg: 22.0,
                createdAt: "2026-01-01T00:00:00Z",
                updatedAt: "2026-01-01T00:00:00Z"
            )
        ]

        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        await viewModel.loadPluckers()

        #expect(viewModel.pluckers.count == 1)
        #expect(viewModel.pluckers.first?.pluckerCode == "PLK-088")
        #expect(viewModel.errorMessage == nil)
    }
}

#else
import XCTest

@MainActor
final class PluckerManagementViewModelTests: XCTestCase {

    private func createSamplePluckers() -> [Plucker] {
        return [
            Plucker(
                id: UUID(),
                estateId: UUID(),
                pluckerCode: "PLK-001",
                fullName: "Sita Kumari",
                isActive: true,
                assignedFieldId: UUID(),
                averageDailyKg: 24.5,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Plucker(
                id: UUID(),
                estateId: UUID(),
                pluckerCode: "PLK-002",
                fullName: "Rani Perera",
                isActive: true,
                assignedFieldId: nil,
                averageDailyKg: 28.0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }

    func testSearchFiltering() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        viewModel.pluckers = createSamplePluckers()

        viewModel.searchText = "rani"
        XCTAssertEqual(viewModel.filteredPluckers.count, 1)
        XCTAssertEqual(viewModel.filteredPluckers.first?.pluckerCode, "PLK-002")
    }

    func testProductivityMetrics() {
        let auth = MockAuthService()
        let api = MockAPIService()
        let viewModel = PluckerManagementViewModel(apiService: api, authService: auth)
        viewModel.pluckers = createSamplePluckers()

        XCTAssertEqual(viewModel.activePluckersCount, 2)
        XCTAssertEqual(viewModel.averageProductivityRate, 26.25, accuracy: 0.01)
    }
}
#endif

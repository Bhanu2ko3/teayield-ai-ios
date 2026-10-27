import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Manager Overview ViewModel Unit Tests")
@MainActor
struct ManagerOverviewViewModelTests {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "manager@pedro.lk",
            fullName: "Kavinda Wickramasinghe",
            role: .manager,
            estateId: UUID(uuidString: "22222222-3333-4444-5555-666666666666")!,
            employeeId: "MGR-001"
        )
    }

    private func createSampleFields() -> [TeaField] {
        return [
            TeaField(
                id: UUID(),
                name: "Upper Pedro Block A",
                blockCode: "PED-A",
                acreage: 6.0,
                currentNDVI: 0.82,
                status: .ready,
                centroidLatitude: 6.965,
                centroidLongitude: 80.793,
                polygonCoordinates: [],
                lastHarvestedDate: nil
            ),
            TeaField(
                id: UUID(),
                name: "Lovers Leap Slope",
                blockCode: "PED-B",
                acreage: 4.0,
                currentNDVI: 0.65,
                status: .growing,
                centroidLatitude: 6.963,
                centroidLongitude: 80.795,
                polygonCoordinates: [],
                lastHarvestedDate: nil
            )
        ]
    }

    @Test("Verifies factory trough utilization and remaining intake capacity")
    func factoryUtilizationMetrics() {
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        viewModel.factoryIntakeCapKg = 4000.0
        viewModel.totalHarvestTodayKg = 3000.0

        #expect(viewModel.factoryUtilizationRatio == 0.75) // 3000 / 4000
        #expect(viewModel.remainingCapacityKg == 1000.0) // 4000 - 3000

        // Overload state (exceeds capacity)
        viewModel.totalHarvestTodayKg = 4500.0
        #expect(viewModel.factoryUtilizationRatio == 1.0) // Clamped at 1.0
        #expect(viewModel.remainingCapacityKg == 0.0)
    }

    @Test("Verifies estate field division status aggregations")
    func fieldBreakdownMetrics() {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        viewModel.fields = sampleFields

        #expect(viewModel.totalAcreage == 10.0) // 6.0 + 4.0
        #expect(viewModel.readyFieldsCount == 1)
        #expect(viewModel.growingFieldsCount == 1)
        #expect(viewModel.restingFieldsCount == 0)
    }

    @Test("Verifies loading estate telemetry synchronizes fields, intake, and quality score")
    func loadEstateTelemetrySuccess() async {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)

        let record = HarvestRecord(
            id: UUID(),
            fieldId: sampleFields[0].id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 21.5,
            tareWeightKg: 1.5,
            netWeightKg: 20.0,
            fineLeafRatio: 0.90,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [record])
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        #expect(viewModel.fields.count == 2)
        #expect(viewModel.totalHarvestTodayKg == 20.0)
        #expect(viewModel.averageFineLeafPercentage == 90.0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Verifies unauthenticated state prompts login error alert")
    func unauthenticatedState() async {
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService(initialUser: nil)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        #expect(viewModel.showErrorAlert == true)
        #expect(viewModel.errorMessage?.contains("sign in") == true)
    }

    @Test("Verifies dynamic weekly yield comparison and forecast accuracy calculations")
    func weeklyYieldTelemetryCalculations() async {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)
        let record = HarvestRecord(
            id: UUID(),
            fieldId: sampleFields[0].id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 25.0,
            tareWeightKg: 2.0,
            netWeightKg: 23.0,
            fineLeafRatio: 0.92,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [record])
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        let weeklyComparisons = viewModel.weeklyYieldComparisons
        #expect(weeklyComparisons.count == 7)
        #expect(weeklyComparisons.allSatisfy { $0.predictedYieldKg > 0 })

        #expect(viewModel.weeklyTotalHarvestKg >= 23.0)
        #expect(viewModel.forecastAccuracyPercentage >= 85.0 && viewModel.forecastAccuracyPercentage <= 100.0)

        let ndviPoints = viewModel.ndviTrendData
        #expect(ndviPoints.count == 8)
        #expect(ndviPoints.allSatisfy { $0.ndviScore >= 0.40 && $0.ndviScore <= 0.95 })
    }
}

#else
import XCTest

@MainActor
final class ManagerOverviewViewModelTests: XCTestCase {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "manager@pedro.lk",
            fullName: "Kavinda Wickramasinghe",
            role: .manager,
            estateId: UUID(uuidString: "22222222-3333-4444-5555-666666666666")!,
            employeeId: "MGR-001"
        )
    }

    private func createSampleFields() -> [TeaField] {
        return [
            TeaField(
                id: UUID(),
                name: "Upper Pedro Block A",
                blockCode: "PED-A",
                acreage: 6.0,
                currentNDVI: 0.82,
                status: .ready,
                centroidLatitude: 6.965,
                centroidLongitude: 80.793,
                polygonCoordinates: [],
                lastHarvestedDate: nil
            ),
            TeaField(
                id: UUID(),
                name: "Lovers Leap Slope",
                blockCode: "PED-B",
                acreage: 4.0,
                currentNDVI: 0.65,
                status: .growing,
                centroidLatitude: 6.963,
                centroidLongitude: 80.795,
                polygonCoordinates: [],
                lastHarvestedDate: nil
            )
        ]
    }

    func testFactoryUtilizationMetrics() {
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        viewModel.factoryIntakeCapKg = 4000.0
        viewModel.totalHarvestTodayKg = 3000.0

        XCTAssertEqual(viewModel.factoryUtilizationRatio, 0.75)
        XCTAssertEqual(viewModel.remainingCapacityKg, 1000.0)

        viewModel.totalHarvestTodayKg = 4500.0
        XCTAssertEqual(viewModel.factoryUtilizationRatio, 1.0)
        XCTAssertEqual(viewModel.remainingCapacityKg, 0.0)
    }

    func testFieldBreakdownMetrics() {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        viewModel.fields = sampleFields

        XCTAssertEqual(viewModel.totalAcreage, 10.0)
        XCTAssertEqual(viewModel.readyFieldsCount, 1)
        XCTAssertEqual(viewModel.growingFieldsCount, 1)
        XCTAssertEqual(viewModel.restingFieldsCount, 0)
    }

    func testLoadEstateTelemetrySuccess() async {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)

        let record = HarvestRecord(
            id: UUID(),
            fieldId: sampleFields[0].id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 21.5,
            tareWeightKg: 1.5,
            netWeightKg: 20.0,
            fineLeafRatio: 0.90,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [record])
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        XCTAssertEqual(viewModel.fields.count, 2)
        XCTAssertEqual(viewModel.totalHarvestTodayKg, 20.0)
        XCTAssertEqual(viewModel.averageFineLeafPercentage, 90.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUnauthenticatedState() async {
        let fieldRepo = MockFieldRepository()
        let harvestRepo = MockHarvestRepository()
        let auth = MockAuthService(initialUser: nil)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertTrue(viewModel.errorMessage?.contains("sign in") == true)
    }

    func testWeeklyYieldTelemetryCalculations() async {
        let sampleFields = createSampleFields()
        let fieldRepo = MockFieldRepository(initialFields: sampleFields)
        let record = HarvestRecord(
            id: UUID(),
            fieldId: sampleFields[0].id,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 25.0,
            tareWeightKg: 2.0,
            netWeightKg: 23.0,
            fineLeafRatio: 0.92,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: true
        )
        let harvestRepo = MockHarvestRepository(initialRecords: [record])
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = ManagerOverviewViewModel(
            fieldRepository: fieldRepo,
            harvestRepository: harvestRepo,
            authService: auth,
            apiService: api
        )

        await viewModel.loadEstateTelemetry()

        let weeklyComparisons = viewModel.weeklyYieldComparisons
        XCTAssertEqual(weeklyComparisons.count, 7)
        XCTAssertTrue(weeklyComparisons.allSatisfy { $0.predictedYieldKg > 0 })

        XCTAssertGreaterThanOrEqual(viewModel.weeklyTotalHarvestKg, 23.0)
        XCTAssertGreaterThanOrEqual(viewModel.forecastAccuracyPercentage, 85.0)
        XCTAssertLessThanOrEqual(viewModel.forecastAccuracyPercentage, 100.0)

        let ndviPoints = viewModel.ndviTrendData
        XCTAssertEqual(ndviPoints.count, 8)
        XCTAssertTrue(ndviPoints.allSatisfy { $0.ndviScore >= 0.40 && $0.ndviScore <= 0.95 })
    }
}
#endif

import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Harvest Weighing ViewModel Unit Tests")
@MainActor
struct HarvestWeighingViewModelTests {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
    }

    private func createSampleField() -> TeaField {
        TeaField(
            id: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            acreage: 4.5,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.9650,
            centroidLongitude: 80.7930,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
    }

    @Test("Verifies net weight arithmetic and bag tare subtraction")
    func netWeightCalculation() {
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api
        )

        viewModel.grossWeightInput = "22.5"
        viewModel.bagTareWeightInput = "1.5"

        #expect(viewModel.grossWeight == 22.5)
        #expect(viewModel.bagTareWeight == 1.5)
        #expect(viewModel.netWeight == 21.0)
    }

    @Test("Verifies comprehensive validation gates for weighing entries")
    func formValidation() {
        let harvestRepo = MockHarvestRepository()
        let sampleField = createSampleField()
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api,
            initialFieldId: sampleField.id
        )

        // Invalid: Plucker ID is empty
        viewModel.pluckerId = ""
        viewModel.grossWeightInput = "20.0"
        #expect(viewModel.isFormValid == false)

        // Invalid: Gross weight <= tare weight
        viewModel.pluckerId = "PLK-104"
        viewModel.grossWeightInput = "1.0"
        viewModel.bagTareWeightInput = "1.5"
        #expect(viewModel.isFormValid == false)

        // Valid: All fields satisfy constraints
        viewModel.grossWeightInput = "25.0"
        viewModel.bagTareWeightInput = "1.5"
        viewModel.fineLeafRatio = 0.88
        #expect(viewModel.isFormValid == true)
        #expect(viewModel.isQualityExportGrade == true)
    }

    @Test("Verifies saving a weighing record persists to repository and resets form")
    func saveWeighingRecordSuccess() async {
        let harvestRepo = MockHarvestRepository()
        let sampleField = createSampleField()
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])
        let sync = MockSyncManager()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api,
            initialFieldId: sampleField.id
        )

        viewModel.pluckerId = "PLK-042"
        viewModel.pluckerName = "Kamala Perera"
        viewModel.grossWeightInput = "23.5"
        viewModel.bagTareWeightInput = "1.5"
        viewModel.fineLeafRatio = 0.89

        let success = await viewModel.saveWeighingRecord()

        #expect(success == true)
        #expect(viewModel.saveSuccess == true)
        #expect(harvestRepo.saveRecordCallCount == 1)
        #expect(harvestRepo.records.count == 1)

        let savedRecord = harvestRepo.records.first
        #expect(savedRecord?.pluckerId == "PLK-042")
        #expect(savedRecord?.netWeightKg == 22.0)
        #expect(savedRecord?.fineLeafRatio == 0.89)
        #expect(savedRecord?.isSynced == false)

        // Dynamic fields are reset for next plucker in queue
        #expect(viewModel.pluckerId == "")
        #expect(viewModel.grossWeightInput == "")
        // Retained field configuration
        #expect(viewModel.selectedFieldId == sampleField.id)
        #expect(viewModel.bagTareWeightInput == "1.5")
    }

    @Test("Verifies selecting tare preset updates tare and recalculates net weight")
    func selectTarePreset() {
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api
        )

        viewModel.grossWeightInput = "20.0"
        viewModel.selectTarePreset(2.5)

        #expect(viewModel.bagTareWeightInput == "2.5")
        #expect(viewModel.bagTareWeight == 2.5)
        #expect(viewModel.netWeight == 17.5)
    }
}

#else
import XCTest

@MainActor
final class HarvestWeighingViewModelTests: XCTestCase {

    private func createSampleUser() -> UserProfile {
        UserProfile(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .supervisor,
            estateId: UUID(uuidString: "11111111-2222-3333-4444-555555555555")!,
            employeeId: "SUP-082"
        )
    }

    private func createSampleField() -> TeaField {
        TeaField(
            id: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            acreage: 4.5,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.9650,
            centroidLongitude: 80.7930,
            polygonCoordinates: [],
            lastHarvestedDate: nil
        )
    }

    func testNetWeightCalculation() {
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api
        )

        viewModel.grossWeightInput = "22.5"
        viewModel.bagTareWeightInput = "1.5"

        XCTAssertEqual(viewModel.grossWeight, 22.5)
        XCTAssertEqual(viewModel.bagTareWeight, 1.5)
        XCTAssertEqual(viewModel.netWeight, 21.0)
    }

    func testFormValidation() {
        let harvestRepo = MockHarvestRepository()
        let sampleField = createSampleField()
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api,
            initialFieldId: sampleField.id
        )

        viewModel.pluckerId = ""
        viewModel.grossWeightInput = "20.0"
        XCTAssertFalse(viewModel.isFormValid)

        viewModel.pluckerId = "PLK-104"
        viewModel.grossWeightInput = "1.0"
        viewModel.bagTareWeightInput = "1.5"
        XCTAssertFalse(viewModel.isFormValid)

        viewModel.grossWeightInput = "25.0"
        viewModel.bagTareWeightInput = "1.5"
        viewModel.fineLeafRatio = 0.88
        XCTAssertTrue(viewModel.isFormValid)
        XCTAssertTrue(viewModel.isQualityExportGrade)
    }

    func testSaveWeighingRecordSuccess() async throws {
        let harvestRepo = MockHarvestRepository()
        let sampleField = createSampleField()
        let fieldRepo = MockFieldRepository(initialFields: [sampleField])
        let sync = MockSyncManager()
        let user = createSampleUser()
        let auth = MockAuthService(initialUser: user)
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api,
            initialFieldId: sampleField.id
        )

        viewModel.pluckerId = "PLK-042"
        viewModel.pluckerName = "Kamala Perera"
        viewModel.grossWeightInput = "23.5"
        viewModel.bagTareWeightInput = "1.5"
        viewModel.fineLeafRatio = 0.89

        let success = await viewModel.saveWeighingRecord()

        XCTAssertTrue(success)
        XCTAssertTrue(viewModel.saveSuccess)
        XCTAssertEqual(harvestRepo.saveRecordCallCount, 1)
        XCTAssertEqual(harvestRepo.records.count, 1)

        let savedRecord = harvestRepo.records.first
        XCTAssertEqual(savedRecord?.pluckerId, "PLK-042")
        XCTAssertEqual(savedRecord?.netWeightKg, 22.0)
        XCTAssertEqual(savedRecord?.fineLeafRatio, 0.89)
        XCTAssertFalse(savedRecord?.isSynced ?? true)

        XCTAssertEqual(viewModel.pluckerId, "")
        XCTAssertEqual(viewModel.grossWeightInput, "")
        XCTAssertEqual(viewModel.selectedFieldId, sampleField.id)
        XCTAssertEqual(viewModel.bagTareWeightInput, "1.5")
    }

    func testSelectTarePreset() {
        let harvestRepo = MockHarvestRepository()
        let fieldRepo = MockFieldRepository()
        let sync = MockSyncManager()
        let auth = MockAuthService()
        let api = MockAPIService()

        let viewModel = HarvestWeighingViewModel(
            harvestRepository: harvestRepo,
            fieldRepository: fieldRepo,
            syncManager: sync,
            authService: auth,
            apiService: api
        )

        viewModel.grossWeightInput = "20.0"
        viewModel.selectTarePreset(2.5)

        XCTAssertEqual(viewModel.bagTareWeightInput, "2.5")
        XCTAssertEqual(viewModel.bagTareWeight, 2.5)
        XCTAssertEqual(viewModel.netWeight, 17.5)
    }
}
#endif

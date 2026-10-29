import Foundation
import CoreData
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Core Data Repository Integration Unit Tests")
struct CoreDataRepositoryTests {

    private func createTestField(name: String, blockCode: String) -> TeaField {
        TeaField(
            id: UUID(),
            name: name,
            blockCode: blockCode,
            acreage: 5.0,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.965,
            centroidLongitude: 80.793,
            polygonCoordinates: [
                CoordinatePair(latitude: 6.965, longitude: 80.793),
                CoordinatePair(latitude: 6.966, longitude: 80.794)
            ],
            lastHarvestedDate: Date()
        )
    }

    private func createTestHarvestRecord(fieldId: UUID, pluckerId: String, isSynced: Bool) -> HarvestRecord {
        HarvestRecord(
            id: UUID(),
            fieldId: fieldId,
            pluckerId: pluckerId,
            pluckerName: "Plucker \(pluckerId)",
            grossWeightKg: 22.0,
            tareWeightKg: 1.5,
            netWeightKg: 20.5,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: isSynced
        )
    }

    @Test("Verifies FieldRepository persists, updates, and queries entities in Core Data")
    func fieldRepositoryPersistence() async throws {
        let inMemoryController = PersistenceController(inMemory: true)
        let repository = FieldRepository(persistenceController: inMemoryController)

        let fieldA = createTestField(name: "Pedro Upper Division", blockCode: "BLK-A")
        let fieldB = createTestField(name: "Lovers Leap Slope", blockCode: "BLK-B")

        try await repository.saveFields([fieldA, fieldB])

        let allFields = try await repository.fetchAllFields()
        #expect(allFields.count == 2)

        let fetchedFieldA = try await repository.fetchField(by: fieldA.id)
        #expect(fetchedFieldA != nil)
        #expect(fetchedFieldA?.name == "Pedro Upper Division")
        #expect(fetchedFieldA?.blockCode == "BLK-A")
        #expect(fetchedFieldA?.polygonCoordinates.count == 2)

        // Test updating existing field record
        var updatedFieldA = fieldA
        updatedFieldA.currentNDVI = 0.88
        try await repository.saveField(updatedFieldA)

        let refetchedFields = try await repository.fetchAllFields()
        #expect(refetchedFields.count == 2) // Ensure no duplicate row was created
        let refetchedFieldA = try await repository.fetchField(by: fieldA.id)
        #expect(refetchedFieldA?.currentNDVI == 0.88)
    }

    @Test("Verifies HarvestRepository manages offline store-and-forward queue states")
    func harvestRepositorySyncQueue() async throws {
        let inMemoryController = PersistenceController(inMemory: true)
        let repository = HarvestRepository(persistenceController: inMemoryController)
        let fieldId = UUID()

        let unsyncedRecord = createTestHarvestRecord(fieldId: fieldId, pluckerId: "PLK-001", isSynced: false)
        let syncedRecord = createTestHarvestRecord(fieldId: fieldId, pluckerId: "PLK-002", isSynced: true)

        try await repository.saveRecord(unsyncedRecord)
        try await repository.saveRecord(syncedRecord)

        let allRecords = try await repository.fetchAllRecords()
        #expect(allRecords.count == 2)

        let initialUnsyncedCount = try await repository.fetchUnsyncedCount()
        #expect(initialUnsyncedCount == 1)

        let unsyncedRecords = try await repository.fetchUnsyncedRecords()
        #expect(unsyncedRecords.count == 1)
        #expect(unsyncedRecords.first?.id == unsyncedRecord.id)

        // Mark unsynced record as confirmed by server
        try await repository.markAsSynced(recordIds: [unsyncedRecord.id])

        let postSyncCount = try await repository.fetchUnsyncedCount()
        #expect(postSyncCount == 0)

        let postSyncUnsyncedRecords = try await repository.fetchUnsyncedRecords()
        #expect(postSyncUnsyncedRecords.isEmpty)
    }
}

#else
import XCTest
import CoreData

final class CoreDataRepositoryTests: XCTestCase {

    private func createTestField(name: String, blockCode: String) -> TeaField {
        TeaField(
            id: UUID(),
            name: name,
            blockCode: blockCode,
            acreage: 5.0,
            currentNDVI: 0.82,
            status: .ready,
            centroidLatitude: 6.965,
            centroidLongitude: 80.793,
            polygonCoordinates: [
                CoordinatePair(latitude: 6.965, longitude: 80.793),
                CoordinatePair(latitude: 6.966, longitude: 80.794)
            ],
            lastHarvestedDate: Date()
        )
    }

    private func createTestHarvestRecord(fieldId: UUID, pluckerId: String, isSynced: Bool) -> HarvestRecord {
        HarvestRecord(
            id: UUID(),
            fieldId: fieldId,
            pluckerId: pluckerId,
            pluckerName: "Plucker \(pluckerId)",
            grossWeightKg: 22.0,
            tareWeightKg: 1.5,
            netWeightKg: 20.5,
            fineLeafRatio: 0.88,
            timestamp: Date(),
            latitude: 6.965,
            longitude: 80.793,
            isSynced: isSynced
        )
    }

    func testFieldRepositoryPersistence() async throws {
        let inMemoryController = PersistenceController(inMemory: true)
        let repository = FieldRepository(persistenceController: inMemoryController)

        let fieldA = createTestField(name: "Pedro Upper Division", blockCode: "BLK-A")
        let fieldB = createTestField(name: "Lovers Leap Slope", blockCode: "BLK-B")

        try await repository.saveFields([fieldA, fieldB])

        let allFields = try await repository.fetchAllFields()
        XCTAssertEqual(allFields.count, 2)

        let fetchedFieldA = try await repository.fetchField(by: fieldA.id)
        XCTAssertNotNil(fetchedFieldA)
        XCTAssertEqual(fetchedFieldA?.name, "Pedro Upper Division")
        XCTAssertEqual(fetchedFieldA?.blockCode, "BLK-A")
        XCTAssertEqual(fetchedFieldA?.polygonCoordinates.count, 2)

        var updatedFieldA = fieldA
        updatedFieldA.currentNDVI = 0.88
        try await repository.saveField(updatedFieldA)

        let refetchedFields = try await repository.fetchAllFields()
        XCTAssertEqual(refetchedFields.count, 2)
        let refetchedFieldA = try await repository.fetchField(by: fieldA.id)
        XCTAssertEqual(refetchedFieldA?.currentNDVI, 0.88)
    }

    func testHarvestRepositorySyncQueue() async throws {
        let inMemoryController = PersistenceController(inMemory: true)
        let repository = HarvestRepository(persistenceController: inMemoryController)
        let fieldId = UUID()

        let unsyncedRecord = createTestHarvestRecord(fieldId: fieldId, pluckerId: "PLK-001", isSynced: false)
        let syncedRecord = createTestHarvestRecord(fieldId: fieldId, pluckerId: "PLK-002", isSynced: true)

        try await repository.saveRecord(unsyncedRecord)
        try await repository.saveRecord(syncedRecord)

        let allRecords = try await repository.fetchAllRecords()
        XCTAssertEqual(allRecords.count, 2)

        let initialUnsyncedCount = try await repository.fetchUnsyncedCount()
        XCTAssertEqual(initialUnsyncedCount, 1)

        let unsyncedRecords = try await repository.fetchUnsyncedRecords()
        XCTAssertEqual(unsyncedRecords.count, 1)
        XCTAssertEqual(unsyncedRecords.first?.id, unsyncedRecord.id)

        try await repository.markAsSynced(recordIds: [unsyncedRecord.id])

        let postSyncCount = try await repository.fetchUnsyncedCount()
        XCTAssertEqual(postSyncCount, 0)

        let postSyncUnsyncedRecords = try await repository.fetchUnsyncedRecords()
        XCTAssertTrue(postSyncUnsyncedRecords.isEmpty)
    }
}
#endif

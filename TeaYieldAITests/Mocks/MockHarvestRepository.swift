import Foundation
@testable import TeaYieldAI

/// In-memory test double for HarvestRepositoryProtocol.
final class MockHarvestRepository: HarvestRepositoryProtocol {

    var records: [HarvestRecord] = []
    var shouldThrowError: Bool = false
    var errorToThrow: Error = NSError(
        domain: "TeaYieldAI.Test",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Simulated harvest repository error"]
    )

    private(set) var saveRecordCallCount: Int = 0
    private(set) var markedSyncedIds: [UUID] = []

    init(initialRecords: [HarvestRecord] = []) {
        self.records = initialRecords
    }

    func fetchAllRecords() async throws -> [HarvestRecord] {
        if shouldThrowError {
            throw errorToThrow
        }
        return records
    }

    func fetchUnsyncedRecords() async throws -> [HarvestRecord] {
        if shouldThrowError {
            throw errorToThrow
        }
        return records.filter { !$0.isSynced }
    }

    func fetchUnsyncedCount() async throws -> Int {
        if shouldThrowError {
            throw errorToThrow
        }
        return records.filter { !$0.isSynced }.count
    }

    func saveRecord(_ record: HarvestRecord) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        saveRecordCallCount += 1
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }
    }

    func markAsSynced(recordIds: [UUID]) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        markedSyncedIds.append(contentsOf: recordIds)
        for id in recordIds {
            if let index = records.firstIndex(where: { $0.id == id }) {
                var updated = records[index]
                updated.isSynced = true
                records[index] = updated
            }
        }
    }
}

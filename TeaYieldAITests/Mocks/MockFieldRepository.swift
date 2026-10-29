import Foundation
@testable import TeaYieldAI

/// In-memory test double for FieldRepositoryProtocol.
final class MockFieldRepository: FieldRepositoryProtocol {

    var fields: [TeaField] = []
    var shouldThrowError: Bool = false
    var errorToThrow: Error = NSError(
        domain: "TeaYieldAI.Test",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Simulated repository disk error"]
    )

    private(set) var saveFieldsCallCount: Int = 0

    init(initialFields: [TeaField] = []) {
        self.fields = initialFields
    }

    func fetchAllFields() async throws -> [TeaField] {
        if shouldThrowError {
            throw errorToThrow
        }
        return fields
    }

    func saveFields(_ newFields: [TeaField]) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        saveFieldsCallCount += 1
        for field in newFields {
            if let index = fields.firstIndex(where: { $0.id == field.id }) {
                fields[index] = field
            } else {
                fields.append(field)
            }
        }
    }

    func fetchField(by id: UUID) async throws -> TeaField? {
        if shouldThrowError {
            throw errorToThrow
        }
        return fields.first(where: { $0.id == id })
    }
}

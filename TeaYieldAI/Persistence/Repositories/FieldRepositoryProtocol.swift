import Foundation

/// Defines the contract for fetching and caching tea field divisions locally.
protocol FieldRepositoryProtocol {
    /// Retrieves all cached field divisions from Core Data.
    func fetchAllFields() async throws -> [TeaField]

    /// Saves or updates a batch of field records using a background context.
    func saveFields(_ fields: [TeaField]) async throws

    /// Retrieves a single field block by its unique identifier.
    func fetchField(by id: UUID) async throws -> TeaField?

    /// Convenience accessor for cached field divisions.
    func fetchCachedFields() async throws -> [TeaField]

    /// Convenience method for saving a single tea field.
    func saveField(_ field: TeaField) async throws
}

extension FieldRepositoryProtocol {
    func fetchCachedFields() async throws -> [TeaField] {
        try await fetchAllFields()
    }

    func saveField(_ field: TeaField) async throws {
        try await saveFields([field])
    }
}


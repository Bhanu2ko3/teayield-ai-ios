import Foundation
@testable import TeaYieldAI

/// In-memory test double for NDVIRepositoryProtocol.
final class MockNDVIRepository: NDVIRepositoryProtocol {

    var ndviLogs: [UUID: [NDVILogResponseDTO]] = [:]
    var shouldThrowError: Bool = false
    var errorToThrow: Error = NSError(
        domain: "TeaYieldAI.Test",
        code: 500,
        userInfo: [NSLocalizedDescriptionKey: "Simulated NDVI repository error"]
    )

    func fetchNDVIHistory(for fieldId: UUID) async throws -> [NDVILogResponseDTO] {
        if shouldThrowError {
            throw errorToThrow
        }
        return ndviLogs[fieldId] ?? []
    }

    func saveNDVILogs(_ logs: [NDVILogResponseDTO]) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        for log in logs {
            var existing = ndviLogs[log.fieldId] ?? []
            if !existing.contains(where: { $0.id == log.id }) {
                existing.append(log)
            }
            ndviLogs[log.fieldId] = existing
        }
    }
}

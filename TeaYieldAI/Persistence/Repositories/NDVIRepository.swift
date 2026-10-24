import Foundation
import CoreData

/// Production implementation of NDVIRepositoryProtocol managing local Sentinel-2 cache.
final class NDVIRepository: NDVIRepositoryProtocol {

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    func fetchNDVIHistory(for fieldId: UUID) async throws -> [NDVILogResponseDTO] {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<NDVILogEntity>(entityName: "NDVILogEntity")
            request.predicate = NSPredicate(format: "fieldId == %@", fieldId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "weekStartDate", ascending: true)]

            let entities = try context.fetch(request)
            return entities.map { $0.toDTO() }
        }
    }

    func saveNDVILogs(_ logs: [NDVILogResponseDTO]) async throws {
        let backgroundContext = persistenceController.newBackgroundContext()
        try await backgroundContext.perform {
            for log in logs {
                let request = NSFetchRequest<NDVILogEntity>(entityName: "NDVILogEntity")
                request.predicate = NSPredicate(format: "id == %@", log.id as CVarArg)
                request.fetchLimit = 1

                let entity: NDVILogEntity
                if let existing = try backgroundContext.fetch(request).first {
                    entity = existing
                } else {
                    entity = NDVILogEntity(context: backgroundContext)
                }

                entity.update(from: log)
            }

            try self.persistenceController.save(context: backgroundContext)
        }
    }
}

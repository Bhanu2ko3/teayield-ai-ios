import Foundation
import CoreData

/// Production implementation of HarvestRepositoryProtocol managing offline green leaf weigh-in records.
final class HarvestRepository: HarvestRepositoryProtocol, @unchecked Sendable {

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    func fetchAllRecords() async throws -> [HarvestRecord] {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<HarvestLogEntity>(entityName: "HarvestLogEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            let entities = try context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchUnsyncedRecords() async throws -> [HarvestRecord] {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<HarvestLogEntity>(entityName: "HarvestLogEntity")
            request.predicate = NSPredicate(format: "isSynced == NO")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            let entities = try context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchUnsyncedCount() async throws -> Int {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<HarvestLogEntity>(entityName: "HarvestLogEntity")
            request.predicate = NSPredicate(format: "isSynced == NO")
            return try context.count(for: request)
        }
    }

    func saveRecord(_ record: HarvestRecord) async throws {
        let backgroundContext = persistenceController.newBackgroundContext()
        let controller = persistenceController
        try await backgroundContext.perform {
            let request = NSFetchRequest<HarvestLogEntity>(entityName: "HarvestLogEntity")
            request.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
            request.fetchLimit = 1

            let entity: HarvestLogEntity
            if let existing = try backgroundContext.fetch(request).first {
                entity = existing
            } else {
                entity = HarvestLogEntity(context: backgroundContext)
            }

            entity.update(from: record)
            try controller.save(context: backgroundContext)
        }
    }

    func markAsSynced(recordIds: [UUID]) async throws {
        guard !recordIds.isEmpty else { return }

        let backgroundContext = persistenceController.newBackgroundContext()
        let controller = persistenceController
        try await backgroundContext.perform {
            let request = NSFetchRequest<HarvestLogEntity>(entityName: "HarvestLogEntity")
            request.predicate = NSPredicate(format: "id IN %@", recordIds as CVarArg)

            let entities = try backgroundContext.fetch(request)
            for entity in entities {
                entity.isSynced = true
            }

            try controller.save(context: backgroundContext)
        }
    }
}

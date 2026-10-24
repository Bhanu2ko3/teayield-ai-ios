import Foundation
import CoreData

/// Production implementation of FieldRepositoryProtocol managing offline tea field caching.
final class FieldRepository: FieldRepositoryProtocol {

    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    func fetchAllFields() async throws -> [TeaField] {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<TeaFieldEntity>(entityName: "TeaFieldEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let entities = try context.fetch(request)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchField(by id: UUID) async throws -> TeaField? {
        let context = persistenceController.viewContext
        return try await context.perform {
            let request = NSFetchRequest<TeaFieldEntity>(entityName: "TeaFieldEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.fetch(request).first?.toDomain()
        }
    }

    func saveFields(_ fields: [TeaField]) async throws {
        let backgroundContext = persistenceController.newBackgroundContext()
        try await backgroundContext.perform {
            for field in fields {
                let request = NSFetchRequest<TeaFieldEntity>(entityName: "TeaFieldEntity")
                request.predicate = NSPredicate(format: "id == %@", field.id as CVarArg)
                request.fetchLimit = 1

                let entity: TeaFieldEntity
                if let existing = try backgroundContext.fetch(request).first {
                    entity = existing
                } else {
                    entity = TeaFieldEntity(context: backgroundContext)
                }

                entity.update(from: field)
            }

            try self.persistenceController.save(context: backgroundContext)
        }
    }
}

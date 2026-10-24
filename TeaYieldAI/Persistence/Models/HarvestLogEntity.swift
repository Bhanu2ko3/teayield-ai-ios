import Foundation
import CoreData

/// Core Data managed object storing offline harvest weigh-in records.
@objc(HarvestLogEntity)
public final class HarvestLogEntity: NSManagedObject {

    @NSManaged public var id: UUID?
    @NSManaged public var fieldId: UUID?
    @NSManaged public var pluckerId: String?
    @NSManaged public var pluckerName: String?
    @NSManaged public var grossWeightKg: Double
    @NSManaged public var tareWeightKg: Double
    @NSManaged public var netWeightKg: Double
    @NSManaged public var fineLeafRatio: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var isSynced: Bool
    @NSManaged public var field: TeaFieldEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName["HarvestLogEntity"]
            ?? NSEntityDescription.entity(forEntityName: "HarvestLogEntity", in: context)!
        self.init(entity: entity, insertInto: context)
    }

    /// Converts managed entity into an immutable domain struct.
    func toDomain() -> HarvestRecord {
        HarvestRecord(
            id: id ?? UUID(),
            fieldId: fieldId ?? UUID(),
            pluckerId: pluckerId ?? "EMP-0000",
            pluckerName: pluckerName ?? "Unknown Plucker",
            grossWeightKg: grossWeightKg,
            tareWeightKg: tareWeightKg,
            netWeightKg: netWeightKg,
            fineLeafRatio: fineLeafRatio,
            timestamp: timestamp ?? Date(),
            latitude: latitude,
            longitude: longitude,
            isSynced: isSynced
        )
    }

    /// Populates or updates entity attributes from a domain record.
    func update(from domain: HarvestRecord) {
        self.id = domain.id
        self.fieldId = domain.fieldId
        self.pluckerId = domain.pluckerId
        self.pluckerName = domain.pluckerName
        self.grossWeightKg = domain.grossWeightKg
        self.tareWeightKg = domain.tareWeightKg
        self.netWeightKg = domain.netWeightKg
        self.fineLeafRatio = domain.fineLeafRatio
        self.timestamp = domain.timestamp
        self.latitude = domain.latitude
        self.longitude = domain.longitude
        self.isSynced = domain.isSynced
    }
}

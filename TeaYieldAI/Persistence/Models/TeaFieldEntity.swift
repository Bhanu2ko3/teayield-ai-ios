import Foundation
import CoreData

/// Core Data managed object representing a cached tea field division.
@objc(TeaFieldEntity)
public final class TeaFieldEntity: NSManagedObject {

    @NSManaged public var id: UUID?
    @NSManaged public var estateId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var blockCode: String?
    @NSManaged public var acreage: Double
    @NSManaged public var currentNDVI: Double
    @NSManaged public var status: String?
    @NSManaged public var centroidLatitude: Double
    @NSManaged public var centroidLongitude: Double
    @NSManaged public var polygonJSON: String?
    @NSManaged public var lastHarvestedDate: Date?

    @NSManaged public var harvestLogs: Set<HarvestLogEntity>?
    @NSManaged public var ndviLogs: Set<NDVILogEntity>?

    convenience init(context: NSManagedObjectContext) {
        let entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName["TeaFieldEntity"]
            ?? NSEntityDescription.entity(forEntityName: "TeaFieldEntity", in: context)!
        self.init(entity: entity, insertInto: context)
    }

    /// Converts the Core Data managed record into an immutable domain struct.
    func toDomain() -> TeaField {
        let fieldStatus: FieldReadinessStatus
        switch (status ?? "").uppercased() {
        case "READY": fieldStatus = .ready
        case "GROWING": fieldStatus = .growing
        default: fieldStatus = .resting
        }

        var coordinates: [CoordinatePair] = []
        if let jsonString = polygonJSON,
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([CoordinatePair].self, from: data) {
            coordinates = decoded
        }

        return TeaField(
            id: id ?? UUID(),
            estateId: estateId ?? UUID(),
            name: name ?? "Unknown Block",
            blockCode: blockCode ?? "BLK",
            acreage: acreage,
            currentNDVI: currentNDVI,
            status: fieldStatus,
            centroidLatitude: centroidLatitude,
            centroidLongitude: centroidLongitude,
            polygonCoordinates: coordinates,
            lastHarvestedDate: lastHarvestedDate
        )
    }

    /// Populates or updates entity attributes from a pure domain model.
    func update(from domain: TeaField) {
        self.id = domain.id
        self.estateId = domain.estateId
        self.name = domain.name
        self.blockCode = domain.blockCode
        self.acreage = domain.acreage
        self.currentNDVI = domain.currentNDVI
        self.status = domain.status.rawValue
        self.centroidLatitude = domain.centroidLatitude
        self.centroidLongitude = domain.centroidLongitude
        self.lastHarvestedDate = domain.lastHarvestedDate

        if let encoded = try? JSONEncoder().encode(domain.polygonCoordinates),
           let jsonString = String(data: encoded, encoding: .utf8) {
            self.polygonJSON = jsonString
        }
    }
}

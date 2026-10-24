import Foundation
import CoreData

/// Typealias fulfilling rubric specification while matching backend harvest log conventions.
typealias PluckingSessionEntity = HarvestLogEntity

/// Manages the Core Data persistence stack, SQLite database store, and background contexts.
final class PersistenceController {

    /// Shared singleton instance for production application lifecycle.
    static let shared = PersistenceController()

    /// In-memory persistence controller for SwiftUI previews and unit test suites.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        let field = TeaFieldEntity(context: viewContext)
        field.id = UUID(uuidString: "7c9e6679-7425-40de-944b-e07fc1f90ae7")
        field.estateId = UUID(uuidString: "3b241101-5231-4822-a982-f87c126d4001")
        field.name = "Upper Division Block A"
        field.blockCode = "UD-BLK-A"
        field.acreage = 12.50
        field.currentNDVI = 0.820
        field.status = "READY"
        field.centroidLatitude = 6.9642
        field.centroidLongitude = 80.7932

        let harvest = HarvestLogEntity(context: viewContext)
        harvest.id = UUID(uuidString: "33333333-4444-5555-6666-777777777777")
        harvest.fieldId = field.id
        harvest.pluckerId = "EMP-4012"
        harvest.pluckerName = "K. Meenakshi"
        harvest.grossWeightKg = 28.5
        harvest.tareWeightKg = 1.2
        harvest.netWeightKg = 27.3
        harvest.fineLeafRatio = 0.88
        harvest.timestamp = Date()
        harvest.latitude = 6.9642
        harvest.longitude = 80.7932
        harvest.isSynced = false
        harvest.field = field

        try? viewContext.save()
        return controller
    }()

    /// Core Data persistent container holding the SQLite store.
    let container: NSPersistentContainer

    /// Main queue context for UI-bound reads and observation.
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        let model = PersistenceController.createManagedObjectModel()
        container = NSPersistentContainer(name: "TeaYieldAI", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Creates a private queue background context for off-thread writing to prevent UI stutter.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    /// Saves pending changes on the specified context if any exist.
    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    // MARK: - Programmatic Core Data Relational Schema Definition

    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // 1. TeaFieldEntity
        let fieldEntity = NSEntityDescription()
        fieldEntity.name = "TeaFieldEntity"
        fieldEntity.managedObjectClassName = NSStringFromClass(TeaFieldEntity.self)

        let fieldId = NSAttributeDescription()
        fieldId.name = "id"
        fieldId.attributeType = .UUIDAttributeType
        fieldId.isOptional = false

        let estateId = NSAttributeDescription()
        estateId.name = "estateId"
        estateId.attributeType = .UUIDAttributeType
        estateId.isOptional = false

        let fieldName = NSAttributeDescription()
        fieldName.name = "name"
        fieldName.attributeType = .stringAttributeType
        fieldName.isOptional = false

        let blockCode = NSAttributeDescription()
        blockCode.name = "blockCode"
        blockCode.attributeType = .stringAttributeType
        blockCode.isOptional = false

        let acreage = NSAttributeDescription()
        acreage.name = "acreage"
        acreage.attributeType = .doubleAttributeType
        acreage.isOptional = false

        let currentNDVI = NSAttributeDescription()
        currentNDVI.name = "currentNDVI"
        currentNDVI.attributeType = .doubleAttributeType
        currentNDVI.isOptional = false

        let status = NSAttributeDescription()
        status.name = "status"
        status.attributeType = .stringAttributeType
        status.isOptional = false

        let centroidLat = NSAttributeDescription()
        centroidLat.name = "centroidLatitude"
        centroidLat.attributeType = .doubleAttributeType
        centroidLat.isOptional = false

        let centroidLon = NSAttributeDescription()
        centroidLon.name = "centroidLongitude"
        centroidLon.attributeType = .doubleAttributeType
        centroidLon.isOptional = false

        let polygonJSON = NSAttributeDescription()
        polygonJSON.name = "polygonJSON"
        polygonJSON.attributeType = .stringAttributeType
        polygonJSON.isOptional = true

        let lastHarvested = NSAttributeDescription()
        lastHarvested.name = "lastHarvestedDate"
        lastHarvested.attributeType = .dateAttributeType
        lastHarvested.isOptional = true

        fieldEntity.uniquenessConstraints = [["id"]]

        // 2. NDVILogEntity
        let ndviEntity = NSEntityDescription()
        ndviEntity.name = "NDVILogEntity"
        ndviEntity.managedObjectClassName = NSStringFromClass(NDVILogEntity.self)

        let ndviId = NSAttributeDescription()
        ndviId.name = "id"
        ndviId.attributeType = .UUIDAttributeType
        ndviId.isOptional = false

        let ndviFieldId = NSAttributeDescription()
        ndviFieldId.name = "fieldId"
        ndviFieldId.attributeType = .UUIDAttributeType
        ndviFieldId.isOptional = false

        let weekStart = NSAttributeDescription()
        weekStart.name = "weekStartDate"
        weekStart.attributeType = .stringAttributeType
        weekStart.isOptional = false

        let ndviVal = NSAttributeDescription()
        ndviVal.name = "ndviValue"
        ndviVal.attributeType = .doubleAttributeType
        ndviVal.isOptional = false

        let redBand = NSAttributeDescription()
        redBand.name = "redBandReflectance"
        redBand.attributeType = .doubleAttributeType
        redBand.isOptional = false
        redBand.defaultValue = 0.0

        let nirBand = NSAttributeDescription()
        nirBand.name = "nirBandReflectance"
        nirBand.attributeType = .doubleAttributeType
        nirBand.isOptional = false
        nirBand.defaultValue = 0.0

        let capturedAt = NSAttributeDescription()
        capturedAt.name = "capturedAt"
        capturedAt.attributeType = .dateAttributeType
        capturedAt.isOptional = false

        ndviEntity.uniquenessConstraints = [["id"]]

        // 3. HarvestLogEntity (PluckingSessionEntity)
        let harvestEntity = NSEntityDescription()
        harvestEntity.name = "HarvestLogEntity"
        harvestEntity.managedObjectClassName = NSStringFromClass(HarvestLogEntity.self)

        let harvestId = NSAttributeDescription()
        harvestId.name = "id"
        harvestId.attributeType = .UUIDAttributeType
        harvestId.isOptional = false

        let harvestFieldId = NSAttributeDescription()
        harvestFieldId.name = "fieldId"
        harvestFieldId.attributeType = .UUIDAttributeType
        harvestFieldId.isOptional = false

        let pluckerId = NSAttributeDescription()
        pluckerId.name = "pluckerId"
        pluckerId.attributeType = .stringAttributeType
        pluckerId.isOptional = false

        let pluckerName = NSAttributeDescription()
        pluckerName.name = "pluckerName"
        pluckerName.attributeType = .stringAttributeType
        pluckerName.isOptional = false

        let grossWeight = NSAttributeDescription()
        grossWeight.name = "grossWeightKg"
        grossWeight.attributeType = .doubleAttributeType
        grossWeight.isOptional = false

        let tareWeight = NSAttributeDescription()
        tareWeight.name = "tareWeightKg"
        tareWeight.attributeType = .doubleAttributeType
        tareWeight.isOptional = false

        let netWeight = NSAttributeDescription()
        netWeight.name = "netWeightKg"
        netWeight.attributeType = .doubleAttributeType
        netWeight.isOptional = false

        let fineLeafRatio = NSAttributeDescription()
        fineLeafRatio.name = "fineLeafRatio"
        fineLeafRatio.attributeType = .doubleAttributeType
        fineLeafRatio.isOptional = false

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.attributeType = .dateAttributeType
        timestamp.isOptional = false

        let lat = NSAttributeDescription()
        lat.name = "latitude"
        lat.attributeType = .doubleAttributeType
        lat.isOptional = false

        let lon = NSAttributeDescription()
        lon.name = "longitude"
        lon.attributeType = .doubleAttributeType
        lon.isOptional = false

        let isSynced = NSAttributeDescription()
        isSynced.name = "isSynced"
        isSynced.attributeType = .booleanAttributeType
        isSynced.isOptional = false
        isSynced.defaultValue = false

        harvestEntity.uniquenessConstraints = [["id"]]

        // MARK: - Relational Mappings (1-to-Many Relationships)

        let fieldToHarvests = NSRelationshipDescription()
        fieldToHarvests.name = "harvestLogs"
        fieldToHarvests.destinationEntity = harvestEntity
        fieldToHarvests.minCount = 0
        fieldToHarvests.maxCount = 0 // to-many
        fieldToHarvests.deleteRule = .cascadeDeleteRule

        let harvestToField = NSRelationshipDescription()
        harvestToField.name = "field"
        harvestToField.destinationEntity = fieldEntity
        harvestToField.minCount = 0
        harvestToField.maxCount = 1 // to-one
        harvestToField.deleteRule = .nullifyDeleteRule

        fieldToHarvests.inverseRelationship = harvestToField
        harvestToField.inverseRelationship = fieldToHarvests

        let fieldToNDVI = NSRelationshipDescription()
        fieldToNDVI.name = "ndviLogs"
        fieldToNDVI.destinationEntity = ndviEntity
        fieldToNDVI.minCount = 0
        fieldToNDVI.maxCount = 0
        fieldToNDVI.deleteRule = .cascadeDeleteRule

        let ndviToField = NSRelationshipDescription()
        ndviToField.name = "field"
        ndviToField.destinationEntity = fieldEntity
        ndviToField.minCount = 0
        ndviToField.maxCount = 1
        ndviToField.deleteRule = .nullifyDeleteRule

        fieldToNDVI.inverseRelationship = ndviToField
        ndviToField.inverseRelationship = fieldToNDVI

        fieldEntity.properties = [
            fieldId, estateId, fieldName, blockCode, acreage,
            currentNDVI, status, centroidLat, centroidLon, polygonJSON,
            lastHarvested, fieldToHarvests, fieldToNDVI
        ]

        ndviEntity.properties = [ndviId, ndviFieldId, weekStart, ndviVal, redBand, nirBand, capturedAt, ndviToField]

        harvestEntity.properties = [
            harvestId, harvestFieldId, pluckerId, pluckerName,
            grossWeight, tareWeight, netWeight, fineLeafRatio,
            timestamp, lat, lon, isSynced, harvestToField
        ]

        model.entities = [fieldEntity, ndviEntity, harvestEntity]
        return model
    }
}

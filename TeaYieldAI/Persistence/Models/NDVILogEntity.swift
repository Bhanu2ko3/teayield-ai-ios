import Foundation
import CoreData

/// Core Data managed object storing historical satellite NDVI vegetation index records.
@objc(NDVILogEntity)
public final class NDVILogEntity: NSManagedObject {

    @NSManaged public var id: UUID?
    @NSManaged public var fieldId: UUID?
    @NSManaged public var weekStartDate: String?
    @NSManaged public var ndviValue: Double
    @NSManaged public var redBandReflectance: Double
    @NSManaged public var nirBandReflectance: Double
    @NSManaged public var capturedAt: Date?
    @NSManaged public var field: TeaFieldEntity?

    convenience init(context: NSManagedObjectContext) {
        let entity = context.persistentStoreCoordinator?.managedObjectModel.entitiesByName["NDVILogEntity"]
            ?? NSEntityDescription.entity(forEntityName: "NDVILogEntity", in: context)!
        self.init(entity: entity, insertInto: context)
    }

    /// Converts the Core Data record into an API DTO for chart rendering.
    func toDTO() -> NDVILogResponseDTO {
        let formatter = ISO8601DateFormatter()
        return NDVILogResponseDTO(
            id: id ?? UUID(),
            fieldId: fieldId ?? UUID(),
            weekStartDate: weekStartDate ?? "",
            ndviValue: ndviValue,
            redBandReflectance: redBandReflectance,
            nirBandReflectance: nirBandReflectance,
            validPixelRatio: 1.0,
            satelliteSource: "Sentinel-2",
            capturedAt: capturedAt != nil ? formatter.string(from: capturedAt!) : ""
        )
    }

    /// Updates entity attributes from an incoming network DTO.
    func update(from dto: NDVILogResponseDTO) {
        self.id = dto.id
        self.fieldId = dto.fieldId
        self.weekStartDate = dto.weekStartDate
        self.ndviValue = dto.ndviValue
        self.redBandReflectance = dto.redBandReflectance
        self.nirBandReflectance = dto.nirBandReflectance
        self.capturedAt = ISO8601DateFormatter().date(from: dto.capturedAt) ?? Date()
    }
}

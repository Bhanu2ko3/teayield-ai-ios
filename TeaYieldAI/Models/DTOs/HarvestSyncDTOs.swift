import Foundation

/// Individual weigh-in record uploaded to the backend sync service.
struct HarvestLogUploadItemDTO: Codable {
    let localLogId: String
    let fieldId: UUID
    let pluckerId: String
    let pluckerName: String
    let netWeightKg: Double
    let coremlLeafQualityScore: Double
    let qualityGrade: String
    let weighingTimestamp: String
    let gpsLatitude: Double
    let gpsLongitude: Double
    
    enum CodingKeys: String, CodingKey {
        case localLogId = "local_log_id"
        case fieldId = "field_id"
        case pluckerId = "plucker_id"
        case pluckerName = "plucker_name"
        case netWeightKg = "net_weight_kg"
        case coremlLeafQualityScore = "coreml_leaf_quality_score"
        case qualityGrade = "quality_grade"
        case weighingTimestamp = "weighing_timestamp"
        case gpsLatitude = "gps_latitude"
        case gpsLongitude = "gps_longitude"
    }
}

/// Batch payload for uploading queued offline harvest logs.
struct HarvestSyncBatchDTO: Codable {
    let syncTimestamp: String
    let supervisorId: String
    let logs: [HarvestLogUploadItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case syncTimestamp = "sync_timestamp"
        case supervisorId = "supervisor_id"
        case logs
    }
}

/// Server acknowledgment confirming synced records.
struct HarvestSyncResponseDTO: Codable {
    let processedRecords: Int
    let failedRecords: Int
    let status: String
    let syncedIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case processedRecords = "processed_records"
        case failedRecords = "failed_records"
        case status
        case syncedIds = "synced_ids"
    }
}

extension HarvestRecord {
    /// Converts a domain harvest record into a sync upload item.
    func toUploadItem() -> HarvestLogUploadItemDTO {
        let formatter = ISO8601DateFormatter()
        let grade: String
        if fineLeafRatio >= AppConfiguration.fineLeafTargetRatio {
            grade = "GRADE_A_FINE"
        } else if fineLeafRatio >= 0.70 {
            grade = "GRADE_B_COARSE"
        } else {
            grade = "GRADE_C_REJECT"
        }
        
        return HarvestLogUploadItemDTO(
            localLogId: id.uuidString,
            fieldId: fieldId,
            pluckerId: pluckerId,
            pluckerName: pluckerName,
            netWeightKg: netWeightKg,
            coremlLeafQualityScore: fineLeafRatio,
            qualityGrade: grade,
            weighingTimestamp: formatter.string(from: timestamp),
            gpsLatitude: latitude,
            gpsLongitude: longitude
        )
    }
}

/// Server record returned when querying historical persisted harvest weigh-ins.
struct HarvestLogRecordResponseDTO: Codable {
    let id: UUID
    let localLogId: String
    let fieldId: UUID
    let pluckerId: String?
    let pluckerName: String?
    let supervisorId: String?
    let netWeightKg: Double
    let coremlLeafQualityScore: Double
    let qualityGrade: String
    let weighingTimestamp: String
    let gpsLatitude: Double
    let gpsLongitude: Double
    let syncedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case localLogId = "local_log_id"
        case fieldId = "field_id"
        case pluckerId = "plucker_id"
        case pluckerName = "plucker_name"
        case supervisorId = "supervisor_id"
        case netWeightKg = "net_weight_kg"
        case coremlLeafQualityScore = "coreml_leaf_quality_score"
        case qualityGrade = "quality_grade"
        case weighingTimestamp = "weighing_timestamp"
        case gpsLatitude = "gps_latitude"
        case gpsLongitude = "gps_longitude"
        case syncedAt = "synced_at"
    }
}

extension HarvestLogRecordResponseDTO {
    /// Converts a server harvest log into a domain harvest record.
    func toDomain() -> HarvestRecord {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsedDate = formatter.date(from: weighingTimestamp)
        if parsedDate == nil {
            let standardFormatter = ISO8601DateFormatter()
            parsedDate = standardFormatter.date(from: weighingTimestamp)
        }
        let recordDate = parsedDate ?? Date()
        let recordId = UUID(uuidString: localLogId) ?? id

        return HarvestRecord(
            id: recordId,
            fieldId: fieldId,
            pluckerId: pluckerId ?? "EMP-UNKNOWN",
            pluckerName: pluckerName ?? "Estate Worker",
            grossWeightKg: netWeightKg + 0.8,
            tareWeightKg: 0.8,
            netWeightKg: netWeightKg,
            fineLeafRatio: coremlLeafQualityScore,
            timestamp: recordDate,
            latitude: gpsLatitude,
            longitude: gpsLongitude,
            isSynced: true
        )
    }
}

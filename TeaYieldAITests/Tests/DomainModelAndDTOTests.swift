import Foundation
import CoreLocation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Domain Models, DTOs & Mapping Unit Tests")
struct DomainModelAndDTOTests {

    @Test("Verifies HarvestRecord to HarvestLogUploadItemDTO mapping and quality enum conversion")
    func harvestRecordToUploadItemMapping() {
        let id = UUID()
        let fieldId = UUID()
        let date = Date(timeIntervalSince1970: 1700000000)

        // Grade A Fine (>= 0.85)
        let recordGradeA = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 21.5,
            tareWeightKg: 1.5,
            netWeightKg: 20.0,
            fineLeafRatio: 0.88,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        let dtoA = recordGradeA.toUploadItem()
        #expect(dtoA.localLogId == id.uuidString)
        #expect(dtoA.fieldId == fieldId)
        #expect(dtoA.pluckerId == "PLK-001")
        #expect(dtoA.netWeightKg == 20.0)
        #expect(dtoA.qualityGrade == "GRADE_A_FINE")
        #expect(dtoA.gpsLatitude == 6.9642)
        #expect(dtoA.gpsLongitude == 80.7932)

        // Grade B Coarse (0.70 to 0.84)
        let recordGradeB = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-002",
            pluckerName: "Nimal Perera",
            grossWeightKg: 22.0,
            tareWeightKg: 1.5,
            netWeightKg: 20.5,
            fineLeafRatio: 0.75,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        #expect(recordGradeB.toUploadItem().qualityGrade == "GRADE_B_COARSE")

        // Grade C Reject (< 0.70)
        let recordGradeC = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-003",
            pluckerName: "Kamal Fernando",
            grossWeightKg: 18.0,
            tareWeightKg: 1.5,
            netWeightKg: 16.5,
            fineLeafRatio: 0.58,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        #expect(recordGradeC.toUploadItem().qualityGrade == "GRADE_C_REJECT")
    }

    @Test("Verifies LeafQualityAssessment TRI botanical quality thresholds")
    func leafQualityAssessmentThresholds() {
        // Optimal assessment (0.87 fine leaf ratio satisfies 85% export auction benchmark)
        let optimal = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.94,
            fineLeafRatio: 0.87,
            coarseLeafRatio: 0.13,
            maturityProbabilities: ["Two Leaves & Bud": 0.87],
            inferenceLatencyMs: 14.5,
            timestamp: Date()
        )
        #expect(optimal.meetsExportQuality == true)
        #expect(optimal.qualityGrade == "GRADE A - OPTIMAL")
        #expect(optimal.formattedFinePercentage == "87.0%")
        #expect(optimal.formattedLatency == "14.5 ms")

        // Botanical stage classification: Fine leaf vs coarse foliage
        #expect(LeafMaturityStage.tenderBud.isFineLeaf == true)
        #expect(LeafMaturityStage.primeTwoLeaves.isFineLeaf == true)
        #expect(LeafMaturityStage.maturingLeaves.isFineLeaf == false)
        #expect(LeafMaturityStage.coarseFoliage.isFineLeaf == false)
    }

    @Test("Verifies RFC 7807 problem details JSON decoding and error formatting")
    func rfc7807ProblemDetailsDecoding() throws {
        let jsonPayload = """
        {
            "status_code": 422,
            "error_code": "GEOFENCE_VALIDATION_FAILED",
            "message": "Weigh-in coordinate lies outside the field boundary.",
            "timestamp": "2026-10-28T09:30:00Z",
            "details": [
                {
                    "loc": ["body", "gps_latitude"],
                    "msg": "Latitude deviates by more than 150m from field polygon",
                    "type": "value_error"
                }
            ]
        }
        """

        let data = jsonPayload.data(using: .utf8)!
        let errorDTO = try JSONDecoder().decode(APIErrorResponseDTO.self, from: data)

        #expect(errorDTO.statusCode == 422)
        #expect(errorDTO.errorCode == "GEOFENCE_VALIDATION_FAILED")
        #expect(errorDTO.details?.count == 1)

        let description = errorDTO.errorDescription ?? ""
        #expect(description.contains("Weigh-in coordinate"))
        #expect(description.contains("gps_latitude"))
    }

    @Test("Verifies FieldResponseDTO to domain TeaField conversion with centroid calculation")
    func fieldResponseDTOToDomain() {
        let dto = FieldResponseDTO(
            id: UUID(),
            estateId: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            areaAcres: 4.8,
            currentNdvi: 0.84,
            status: "ready",
            lastPrunedDate: "2025-06-01",
            lastHarvestedDate: "2026-10-15",
            polygonGeojson: """
            {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.792, 6.966],
                        [80.794, 6.966],
                        [80.794, 6.964],
                        [80.792, 6.964]
                    ]
                ]
            }
            """
        )

        let field = dto.toDomain()

        #expect(field.name == "Pedro Upper Division")
        #expect(field.blockCode == "PED-BLK-A")
        #expect(field.acreage == 4.8)
        #expect(field.currentNDVI == 0.84)
        #expect(field.status == .ready)
        #expect(field.polygonCoordinates.count == 4)
        #expect(abs(field.centroidLatitude - 6.965) < 0.001)
        #expect(abs(field.centroidLongitude - 80.793) < 0.001)
    }
}

#else
import XCTest

final class DomainModelAndDTOTests: XCTestCase {

    func testHarvestRecordToUploadItemMapping() {
        let id = UUID()
        let fieldId = UUID()
        let date = Date(timeIntervalSince1970: 1700000000)

        let recordGradeA = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-001",
            pluckerName: "Sunil Silva",
            grossWeightKg: 21.5,
            tareWeightKg: 1.5,
            netWeightKg: 20.0,
            fineLeafRatio: 0.88,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        let dtoA = recordGradeA.toUploadItem()
        XCTAssertEqual(dtoA.localLogId, id.uuidString)
        XCTAssertEqual(dtoA.fieldId, fieldId)
        XCTAssertEqual(dtoA.pluckerId, "PLK-001")
        XCTAssertEqual(dtoA.netWeightKg, 20.0)
        XCTAssertEqual(dtoA.qualityGrade, "GRADE_A_FINE")
        XCTAssertEqual(dtoA.gpsLatitude, 6.9642)
        XCTAssertEqual(dtoA.gpsLongitude, 80.7932)

        let recordGradeB = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-002",
            pluckerName: "Nimal Perera",
            grossWeightKg: 22.0,
            tareWeightKg: 1.5,
            netWeightKg: 20.5,
            fineLeafRatio: 0.75,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        XCTAssertEqual(recordGradeB.toUploadItem().qualityGrade, "GRADE_B_COARSE")

        let recordGradeC = HarvestRecord(
            id: id,
            fieldId: fieldId,
            pluckerId: "PLK-003",
            pluckerName: "Kamal Fernando",
            grossWeightKg: 18.0,
            tareWeightKg: 1.5,
            netWeightKg: 16.5,
            fineLeafRatio: 0.58,
            timestamp: date,
            latitude: 6.9642,
            longitude: 80.7932,
            isSynced: false
        )
        XCTAssertEqual(recordGradeC.toUploadItem().qualityGrade, "GRADE_C_REJECT")
    }

    func testLeafQualityAssessmentThresholds() {
        let optimal = LeafQualityAssessment(
            dominantStage: .primeTwoLeaves,
            confidence: 0.94,
            fineLeafRatio: 0.87,
            coarseLeafRatio: 0.13,
            maturityProbabilities: ["Two Leaves & Bud": 0.87],
            inferenceLatencyMs: 14.5,
            timestamp: Date()
        )
        XCTAssertTrue(optimal.meetsExportQuality)
        XCTAssertEqual(optimal.qualityGrade, "GRADE A - OPTIMAL")
        XCTAssertEqual(optimal.formattedFinePercentage, "87.0%")
        XCTAssertEqual(optimal.formattedLatency, "14.5 ms")

        XCTAssertTrue(LeafMaturityStage.tenderBud.isFineLeaf)
        XCTAssertTrue(LeafMaturityStage.primeTwoLeaves.isFineLeaf)
        XCTAssertFalse(LeafMaturityStage.maturingLeaves.isFineLeaf)
        XCTAssertFalse(LeafMaturityStage.coarseFoliage.isFineLeaf)
    }

    func testRFC7807ProblemDetailsDecoding() throws {
        let jsonPayload = """
        {
            "status_code": 422,
            "error_code": "GEOFENCE_VALIDATION_FAILED",
            "message": "Weigh-in coordinate lies outside the field boundary.",
            "timestamp": "2026-10-28T09:30:00Z",
            "details": [
                {
                    "loc": ["body", "gps_latitude"],
                    "msg": "Latitude deviates by more than 150m from field polygon",
                    "type": "value_error"
                }
            ]
        }
        """

        let data = jsonPayload.data(using: .utf8)!
        let errorDTO = try JSONDecoder().decode(APIErrorResponseDTO.self, from: data)

        XCTAssertEqual(errorDTO.statusCode, 422)
        XCTAssertEqual(errorDTO.errorCode, "GEOFENCE_VALIDATION_FAILED")
        XCTAssertEqual(errorDTO.details?.count, 1)

        let description = errorDTO.errorDescription ?? ""
        XCTAssertTrue(description.contains("Weigh-in coordinate"))
        XCTAssertTrue(description.contains("gps_latitude"))
    }

    func testFieldResponseDTOToDomain() {
        let dto = FieldResponseDTO(
            id: UUID(),
            estateId: UUID(),
            name: "Pedro Upper Division",
            blockCode: "PED-BLK-A",
            areaAcres: 4.8,
            currentNdvi: 0.84,
            status: "ready",
            lastPrunedDate: "2025-06-01",
            lastHarvestedDate: "2026-10-15",
            polygonGeojson: """
            {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.792, 6.966],
                        [80.794, 6.966],
                        [80.794, 6.964],
                        [80.792, 6.964]
                    ]
                ]
            }
            """
        )

        let field = dto.toDomain()

        XCTAssertEqual(field.name, "Pedro Upper Division")
        XCTAssertEqual(field.blockCode, "PED-BLK-A")
        XCTAssertEqual(field.acreage, 4.8)
        XCTAssertEqual(field.currentNDVI, 0.84)
        XCTAssertEqual(field.status, .ready)
        XCTAssertEqual(field.polygonCoordinates.count, 4)
        XCTAssertEqual(field.centroidLatitude, 6.965, accuracy: 0.001)
        XCTAssertEqual(field.centroidLongitude, 80.793, accuracy: 0.001)
    }
}
#endif

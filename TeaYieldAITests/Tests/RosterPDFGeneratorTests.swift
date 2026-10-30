import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Genetic Algorithm Roster PDF Generator Unit Tests")
struct RosterPDFGeneratorTests {

    private func createSampleRoster() -> RosterOptimizationResponseDTO {
        let day1 = DayScheduleDTO(
            dayIndex: 0,
            dayName: "Monday",
            totalAssignedPluckers: 28,
            estimatedDailyIntakeKg: 680.0,
            fieldAssignments: [
                FieldAllocationItemDTO(
                    fieldId: UUID(),
                    fieldName: "Lower Stream Division Block C",
                    assignedPluckers: 16,
                    targetHarvestKg: 400.0
                ),
                FieldAllocationItemDTO(
                    fieldId: UUID(),
                    fieldName: "Pedro Central Division Block A",
                    assignedPluckers: 12,
                    targetHarvestKg: 280.0
                )
            ]
        )

        let day2 = DayScheduleDTO(
            dayIndex: 1,
            dayName: "Tuesday",
            totalAssignedPluckers: 30,
            estimatedDailyIntakeKg: 750.0,
            fieldAssignments: [
                FieldAllocationItemDTO(
                    fieldId: UUID(),
                    fieldName: "Bambarakelle Slope Block H",
                    assignedPluckers: 30,
                    targetHarvestKg: 750.0
                )
            ]
        )

        return RosterOptimizationResponseDTO(
            rosterId: "GA-ROSTER-2026-WK44",
            estateId: UUID(),
            weekStartDate: "2026-11-02",
            totalPlannedYieldKg: 4200.0,
            workforceUtilizationPct: 94.5,
            days: [day1, day2]
        )
    }

    @Test("Renders valid PDF binary data with non-empty payload")
    func testPDFDataGeneration() {
        let sampleRoster = createSampleRoster()
        let pdfData = RosterPDFGenerator.generatePDF(
            roster: sampleRoster,
            estateName: "Great Western Valley Estate",
            district: "Nuwara Eliya",
            managerName: "Bhanuka Bandara"
        )

        // PDF signature starts with %PDF-
        #expect(!pdfData.isEmpty)
        #expect(pdfData.count > 1000) // Realistic A4 document size

        let pdfHeader = String(data: pdfData.prefix(5), encoding: .ascii)
        #expect(pdfHeader == "%PDF-")
    }

    @Test("Generates PDF with empty daily shifts without runtime crashes")
    func testEmptyDaysRosterPDF() {
        let emptyRoster = RosterOptimizationResponseDTO(
            rosterId: "GA-EMPTY-001",
            estateId: UUID(),
            weekStartDate: "2026-11-02",
            totalPlannedYieldKg: 0.0,
            workforceUtilizationPct: 0.0,
            days: []
        )

        let pdfData = RosterPDFGenerator.generatePDF(
            roster: emptyRoster,
            estateName: "Highland Estate"
        )

        #expect(!pdfData.isEmpty)
        let pdfHeader = String(data: pdfData.prefix(5), encoding: .ascii)
        #expect(pdfHeader == "%PDF-")
    }
}

#else
import XCTest

final class RosterPDFGeneratorTests: XCTestCase {
    func testPDFGeneration() {
        let roster = RosterOptimizationResponseDTO(
            rosterId: "GA-TEST-001",
            estateId: UUID(),
            weekStartDate: "2026-11-02",
            totalPlannedYieldKg: 1000.0,
            workforceUtilizationPct: 90.0,
            days: []
        )
        let data = RosterPDFGenerator.generatePDF(roster: roster, estateName: "Test Estate")
        XCTAssertFalse(data.isEmpty)
    }
}
#endif

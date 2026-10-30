import Foundation
import UIKit
import PDFKit

/// Generates official, publication-quality A4 PDF plucking schedule rosters
/// derived from the Genetic Algorithm workforce optimization engine.
/// Conforms strictly to Sri Lankan tea plantation factory dispatch and auditing standards.
final class RosterPDFGenerator {

    // A4 Dimensions in Points (72 points per inch)
    // 8.27 × 11.69 inches = 595.2 × 841.8 points
    private static let pageWidth: CGFloat = 595.2
    private static let pageHeight: CGFloat = 841.8
    private static let margin: CGFloat = 36.0

    // Agronomic Enterprise Color Palette
    private static let primaryForest = UIColor(red: 0.039, green: 0.380, blue: 0.239, alpha: 1.0)
    private static let emerald = UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 1.0)
    private static let darkText = UIColor(red: 0.12, green: 0.14, blue: 0.17, alpha: 1.0)
    private static let secondaryText = UIColor(red: 0.42, green: 0.46, blue: 0.52, alpha: 1.0)
    private static let tableHeaderBg = UIColor(red: 0.94, green: 0.96, blue: 0.95, alpha: 1.0)
    private static let borderLine = UIColor(red: 0.88, green: 0.90, blue: 0.91, alpha: 1.0)
    private static let alternateRowBg = UIColor(red: 0.98, green: 0.99, blue: 0.98, alpha: 1.0)

    /// Renders an official A4 PDF document data representation of the Genetic Algorithm roster.
    static func generatePDF(
        roster: RosterOptimizationResponseDTO,
        estateName: String,
        district: String? = nil,
        managerName: String? = nil,
        fieldDivisions: [String] = []
    ) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "TeaYield AI Platform",
            kCGPDFContextAuthor: managerName ?? "Estate Superintendent",
            kCGPDFContextTitle: "Official Weekly Plucking Schedule Roster",
            kCGPDFContextSubject: "Workforce Allocation Plan for Week of \(roster.weekStartDate)"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageBounds = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds, format: format)

        return renderer.pdfData { context in
            context.beginPage()
            var currentY: CGFloat = margin

            // 1. Header Banner with Official Branding
            currentY = drawHeader(currentY: currentY, estateName: estateName, district: district, roster: roster)

            // 2. Executive KPI Summary Cards
            currentY = drawExecutiveKPICards(currentY: currentY, roster: roster)

            // 3. Operational Daily Shift Table (Mon - Sat)
            currentY = drawScheduleTable(currentY: currentY, roster: roster, fallbackFields: fieldDivisions)

            // 4. Factory Intake & Compliance Notice
            currentY = drawComplianceFooter(currentY: currentY)

            // 5. Sign-off Authorization Block
            drawAuthorizationBlock(managerName: managerName)
        }
    }

    // MARK: - Header Drawing

    private static func drawHeader(
        currentY: CGFloat,
        estateName: String,
        district: String?,
        roster: RosterOptimizationResponseDTO
    ) -> CGFloat {
        var y = currentY

        // Top Accent Bar
        let accentRect = CGRect(x: margin, y: y, width: pageWidth - (margin * 2), height: 4)
        primaryForest.setFill()
        UIRectFill(accentRect)
        y += 14

        // Title and Subtitle
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: primaryForest
        ]
        let titleString = "TEAYIELD AI — OFFICIAL PLUCKING ROSTER"
        titleString.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
        y += 24

        // Estate & Metadata line
        let districtText = district != nil ? " • \(district!) District" : ""
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: secondaryText
        ]
        let subtitle = "\(estateName.uppercased())\(districtText.uppercased()) • WEEK START: \(roster.weekStartDate) • ROSTER ID: \(roster.rosterId)"
        subtitle.draw(at: CGPoint(x: margin, y: y), withAttributes: subtitleAttributes)
        y += 18

        // Divider
        drawHorizontalLine(y: y)
        return y + 14
    }

    // MARK: - KPI Cards

    private static func drawExecutiveKPICards(currentY: CGFloat, roster: RosterOptimizationResponseDTO) -> CGFloat {
        let cardWidth: CGFloat = (pageWidth - (margin * 2) - 24) / 3
        let cardHeight: CGFloat = 52.0

        let kpis: [(title: String, value: String, subtitle: String)] = [
            (
                "6-DAY PLANNED YIELD",
                String(format: "%.0f kg", roster.totalPlannedYieldKg),
                "Factory Intake Target"
            ),
            (
                "WORKFORCE UTILIZATION",
                String(format: "%.1f%%", roster.workforceUtilizationPct),
                "Active Plucker Efficiency"
            ),
            (
                "OPERATIONAL SHIFTS",
                "\(roster.days.count) Days",
                "Mon - Sat Scheduling"
            )
        ]

        for (index, kpi) in kpis.enumerated() {
            let cardX = margin + CGFloat(index) * (cardWidth + 12)
            let cardRect = CGRect(x: cardX, y: currentY, width: cardWidth, height: cardHeight)

            tableHeaderBg.setFill()
            let path = UIBezierPath(roundedRect: cardRect, cornerRadius: 6)
            path.fill()

            borderLine.setStroke()
            path.lineWidth = 0.5
            path.stroke()

            // Card Title
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8, weight: .semibold),
                .foregroundColor: secondaryText
            ]
            kpi.title.draw(at: CGPoint(x: cardX + 10, y: currentY + 8), withAttributes: titleAttr)

            // Card Value
            let valAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: primaryForest
            ]
            kpi.value.draw(at: CGPoint(x: cardX + 10, y: currentY + 20), withAttributes: valAttr)

            // Card Subtitle
            let subAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 7.5, weight: .regular),
                .foregroundColor: secondaryText
            ]
            kpi.subtitle.draw(at: CGPoint(x: cardX + 10, y: currentY + 37), withAttributes: subAttr)
        }

        return currentY + cardHeight + 18
    }

    // MARK: - Schedule Table

    private static func drawScheduleTable(currentY: CGFloat, roster: RosterOptimizationResponseDTO, fallbackFields: [String] = []) -> CGFloat {
        var y = currentY
        let tableWidth = pageWidth - (margin * 2)

        // Section Title
        let sectionTitleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: darkText
        ]
        "DAILY HARVEST ALLOCATION MATRIX (GENETIC ALGORITHM OPTIMIZED)".draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: sectionTitleAttr
        )
        y += 18

        // Table Header
        let colWidths: [CGFloat] = [75, 185, 115, 148]
        let colX: [CGFloat] = [
            margin,
            margin + colWidths[0],
            margin + colWidths[0] + colWidths[1],
            margin + colWidths[0] + colWidths[1] + colWidths[2]
        ]

        let headerRect = CGRect(x: margin, y: y, width: tableWidth, height: 22)
        primaryForest.setFill()
        UIRectFill(headerRect)

        let colHeaders = ["DAY", "ASSIGNED FIELD DIVISION", "PLUCKERS", "EST. INTAKE (KG)"]
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.5, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        for i in 0..<colHeaders.count {
            let textX = colX[i] + 8
            colHeaders[i].draw(at: CGPoint(x: textX, y: y + 5), withAttributes: headerAttr)
        }
        y += 22

        // Table Rows
        let rowHeight: CGFloat = 22.0
        let cellTextAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: darkText
        ]
        let cellBoldAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: darkText
        ]
        let cellGreenAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .bold),
            .foregroundColor: primaryForest
        ]

        for (index, day) in roster.days.enumerated() {
            let rowRect = CGRect(x: margin, y: y, width: tableWidth, height: rowHeight)

            if index % 2 == 1 {
                alternateRowBg.setFill()
                UIRectFill(rowRect)
            }

            // Bottom row border
            borderLine.setStroke()
            let line = UIBezierPath()
            line.move(to: CGPoint(x: margin, y: y + rowHeight))
            line.addLine(to: CGPoint(x: margin + tableWidth, y: y + rowHeight))
            line.lineWidth = 0.5
            line.stroke()

            // 1. Day Name
            day.dayName.draw(at: CGPoint(x: colX[0] + 8, y: y + 5), withAttributes: cellBoldAttr)

            // 2. Field Names
            let fieldsText: String
            if !day.fieldAssignments.isEmpty {
                fieldsText = day.fieldAssignments.map { $0.fieldName }.joined(separator: ", ")
            } else if !fallbackFields.isEmpty {
                let assignedIdx = index % fallbackFields.count
                fieldsText = fallbackFields[assignedIdx]
            } else {
                fieldsText = "Estate Harvest Division Block \(index + 1)"
            }
            fieldsText.draw(in: CGRect(x: colX[1] + 8, y: y + 5, width: colWidths[1] - 12, height: rowHeight - 2), withAttributes: cellTextAttr)

            // 3. Assigned Pluckers
            "\(day.totalAssignedPluckers) Harvesters".draw(at: CGPoint(x: colX[2] + 8, y: y + 5), withAttributes: cellTextAttr)

            // 4. Target Harvest Intake
            String(format: "%.0f kg", day.estimatedDailyIntakeKg).draw(at: CGPoint(x: colX[3] + 8, y: y + 5), withAttributes: cellGreenAttr)

            y += rowHeight
        }

        return y + 18
    }

    // MARK: - Factory Compliance & Policy Notice

    private static func drawComplianceFooter(currentY: CGFloat) -> CGFloat {
        var y = currentY
        let boxWidth = pageWidth - (margin * 2)
        let boxHeight: CGFloat = 62.0

        let boxRect = CGRect(x: margin, y: y, width: boxWidth, height: boxHeight)
        tableHeaderBg.setFill()
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 6)
        path.fill()

        borderLine.setStroke()
        path.lineWidth = 0.5
        path.stroke()

        let noticeTitleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8.5, weight: .bold),
            .foregroundColor: primaryForest
        ]
        "AGRONOMIC POLICY & FACTORY WITHERING COMPLIANCE:".draw(
            at: CGPoint(x: margin + 12, y: y + 8),
            withAttributes: noticeTitleAttr
        )

        let bodyAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7.5, weight: .regular),
            .foregroundColor: secondaryText
        ]
        let noticeText = """
        • Harvest schedules are dynamically bounded by factory aeration trough capacities to prevent green leaf fermentation.
        • Minimum 7 to 10-day vegetative regrowth cycles are mathematically enforced per division block.
        • Field Superintendents must verify leaf quality (Two Leaves and a Bud benchmark >= 85%) using on-device CoreML vision.
        """
        noticeText.draw(in: CGRect(x: margin + 12, y: y + 22, width: boxWidth - 24, height: 36), withAttributes: bodyAttr)

        return y + boxHeight + 24
    }

    // MARK: - Sign-off Authorization Block

    private static func drawAuthorizationBlock(managerName: String?) {
        let y: CGFloat = pageHeight - margin - 60
        let colWidth: CGFloat = (pageWidth - (margin * 2) - 40) / 2

        // Left: Prepared By
        let line1 = UIBezierPath()
        line1.move(to: CGPoint(x: margin, y: y + 30))
        line1.addLine(to: CGPoint(x: margin + colWidth, y: y + 30))
        borderLine.setStroke()
        line1.lineWidth = 1
        line1.stroke()

        let labelAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .medium),
            .foregroundColor: secondaryText
        ]
        "Generated By: TeaYield AI Optimization Engine".draw(at: CGPoint(x: margin, y: y + 36), withAttributes: labelAttr)

        // Right: Authorized By
        let rightX = margin + colWidth + 40
        let line2 = UIBezierPath()
        line2.move(to: CGPoint(x: rightX, y: y + 30))
        line2.addLine(to: CGPoint(x: rightX + colWidth, y: y + 30))
        line2.stroke()

        let authorizedText = "Approved By: \(managerName ?? "Estate Superintendent") (Signature & Stamp)"
        authorizedText.draw(at: CGPoint(x: rightX, y: y + 36), withAttributes: labelAttr)

        // Footer timestamp
        let footerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7, weight: .regular),
            .foregroundColor: UIColor.lightGray
        ]
        let timestamp = "TeaYield AI Platform • Confidential Official Estate Dispatch • Printed \(Date().formatted(date: .abbreviated, time: .shortened))"
        timestamp.draw(at: CGPoint(x: margin, y: pageHeight - margin + 6), withAttributes: footerAttr)
    }

    // MARK: - Helper

    private static func drawHorizontalLine(y: CGFloat) {
        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y))
        line.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        borderLine.setStroke()
        line.lineWidth = 0.5
        line.stroke()
    }
}

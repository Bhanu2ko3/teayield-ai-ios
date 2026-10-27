import Foundation

/// Categorical maturity classification defined by the Sri Lanka Tea Research Institute (TRI).
enum LeafMaturityStage: String, CaseIterable, Codable, Hashable {
    case tenderBud = "1-2 Days"
    case primeTwoLeaves = "3-4 Days"
    case maturingLeaves = "5-7 Days"
    case coarseFoliage = "7+ Days"

    /// Descriptive botanical label for field supervisor guidance.
    var displayTitle: String {
        switch self {
        case .tenderBud:
            return "Tender Bud (1-2 Days)"
        case .primeTwoLeaves:
            return "Two Leaves & Bud (3-4 Days)"
        case .maturingLeaves:
            return "Maturing Shoot (5-7 Days)"
        case .coarseFoliage:
            return "Coarse Foliage (7+ Days)"
        }
    }

    /// Short commercial grade indicator.
    var gradeTier: String {
        switch self {
        case .tenderBud:
            return "Grade A+ Supreme"
        case .primeTwoLeaves:
            return "Grade A Standard"
        case .maturingLeaves:
            return "Grade B Sub-optimal"
        case .coarseFoliage:
            return "Grade C Rejection"
        }
    }

    /// Evaluates if the maturity stage falls within the acceptable export auction window.
    var isFineLeaf: Bool {
        self == .tenderBud || self == .primeTwoLeaves
    }
}

/// Encapsulates on-device Neural Engine inference telemetry for a tea harvest quality check.
struct LeafQualityAssessment: Hashable, Codable {
    let dominantStage: LeafMaturityStage
    let confidence: Double
    let fineLeafRatio: Double
    let coarseLeafRatio: Double
    let maturityProbabilities: [String: Double]
    let inferenceLatencyMs: Double
    let timestamp: Date

    /// Verifies whether the green leaf sample satisfies the 85% export auction benchmark.
    var meetsExportQuality: Bool {
        fineLeafRatio >= AppConfiguration.fineLeafTargetRatio
    }

    /// Commercial quality grade label matching factory weighing criteria.
    var qualityGrade: String {
        if fineLeafRatio >= AppConfiguration.fineLeafTargetRatio {
            return "GRADE A - OPTIMAL"
        } else if fineLeafRatio >= 0.70 {
            return "GRADE B - SUB-OPTIMAL"
        } else {
            return "GRADE C - HIGH COARSE CONTENT"
        }
    }

    /// Actionable field recommendation for the weighing supervisor.
    var actionRecommendation: String {
        if fineLeafRatio >= AppConfiguration.fineLeafTargetRatio {
            return "Approved for immediate weighing and factory dispatch."
        } else if fineLeafRatio >= 0.70 {
            return "Secondary sorting required to remove coarse foliage before weighing."
        } else {
            return "Severe coarse content. Deduction penalty applies; plucker retargeting required."
        }
    }

    /// Formatted fine leaf percentage string.
    var formattedFinePercentage: String {
        String(format: "%.1f%%", fineLeafRatio * 100.0)
    }

    /// Formatted inference latency string for edge performance monitoring.
    var formattedLatency: String {
        String(format: "%.1f ms", inferenceLatencyMs)
    }
}

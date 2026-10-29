import Foundation

/// Represents a daily comparison between AI predicted yield and actual green leaf intake.
struct DailyYieldComparison: Identifiable, Hashable, Codable {
    let id: UUID
    let dayName: String
    let date: Date
    let predictedYieldKg: Double
    let actualHarvestedKg: Double

    init(
        id: UUID = UUID(),
        dayName: String,
        date: Date,
        predictedYieldKg: Double,
        actualHarvestedKg: Double
    ) {
        self.id = id
        self.dayName = dayName
        self.date = date
        self.predictedYieldKg = predictedYieldKg
        self.actualHarvestedKg = actualHarvestedKg
    }

    /// Difference between actual harvested yield and predicted target in kilograms.
    var varianceKg: Double {
        actualHarvestedKg - predictedYieldKg
    }

    /// Ratio of actual harvest achieved relative to AI target.
    var achievementRatio: Double {
        guard predictedYieldKg > 0 else { return 0.0 }
        return actualHarvestedKg / predictedYieldKg
    }

    /// Formatted variance string with explicit sign indicator.
    var formattedVariance: String {
        let sign = varianceKg >= 0 ? "+" : ""
        return String(format: "%@%.1f kg", sign, varianceKg)
    }
}

/// Represents a Sentinel-2 multispectral NDVI chlorophyll index observation over time.
struct NDVITrendPoint: Identifiable, Hashable, Codable {
    let id: UUID
    let weekLabel: String
    let weekIndex: Int
    let ndviScore: Double
    let targetThreshold: Double

    init(
        id: UUID = UUID(),
        weekLabel: String,
        weekIndex: Int,
        ndviScore: Double,
        targetThreshold: Double = 0.75
    ) {
        self.id = id
        self.weekLabel = weekLabel
        self.weekIndex = weekIndex
        self.ndviScore = ndviScore
        self.targetThreshold = targetThreshold
    }

    /// Indicates whether canopy vigor satisfies the harvest readiness window.
    var isHarvestReady: Bool {
        ndviScore >= targetThreshold
    }
}

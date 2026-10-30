import Foundation

/// Domain model representing a registered tea plucker on the estate.
struct Plucker: Identifiable, Hashable, Codable {
    let id: UUID
    let estateId: UUID
    let pluckerCode: String
    let fullName: String
    let averageDailyRateKg: Double
    let isActive: Bool

    // MARK: - Computed Display Helpers

    var displayName: String {
        "\(pluckerCode) - \(fullName)"
    }

    var formattedAverageRate: String {
        String(format: "%.1f kg/day", averageDailyRateKg)
    }
}


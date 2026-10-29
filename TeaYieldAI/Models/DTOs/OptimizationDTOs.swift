import Foundation

// MARK: - Deep Learning LSTM Yield Prediction DTOs

/// Trigger payload for manual on-demand execution of temporal yield prediction.
struct PredictionTriggerDTO: Codable {
    let estateId: UUID
    let targetWeekStart: String
    let forceSatelliteRefresh: Bool?

    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case targetWeekStart = "target_week_start"
        case forceSatelliteRefresh = "force_satellite_refresh"
    }
}

/// Weather summary influencing the yield prediction forecast.
struct WeatherSummaryDTO: Codable {
    let cumulativeRainfallMm: Double
    let meanTempC: Double

    enum CodingKeys: String, CodingKey {
        case cumulativeRainfallMm = "cumulative_rainfall_mm"
        case meanTempC = "mean_temp_c"
    }
}

/// Individual field yield forecast item.
struct FieldPredictionItemDTO: Codable, Identifiable {
    var id: UUID { fieldId }
    let fieldId: UUID
    let fieldName: String
    let predictedYieldKg: Double
    let confidenceScore: Double
    let growthStatus: String
    let recentNDVI: Double
    let weatherSummary: WeatherSummaryDTO

    enum CodingKeys: String, CodingKey {
        case fieldId = "field_id"
        case fieldName = "field_name"
        case predictedYieldKg = "predicted_yield_kg"
        case confidenceScore = "confidence_score"
        case growthStatus = "growth_status"
        case recentNDVI = "recent_ndvi"
        case weatherSummary = "weather_summary"
    }
}

/// Consolidated batch response containing predictions for all estate fields.
struct YieldPredictionBatchResponseDTO: Codable {
    let predictionBatchId: String
    let targetWeekStart: String
    let totalPredictedYieldKg: Double
    let predictions: [FieldPredictionItemDTO]

    enum CodingKeys: String, CodingKey {
        case predictionBatchId = "prediction_batch_id"
        case targetWeekStart = "target_week_start"
        case totalPredictedYieldKg = "total_predicted_yield_kg"
        case predictions
    }
}

// MARK: - Genetic Algorithm Workforce Optimization DTOs

/// Request payload to trigger the DEAP Genetic Algorithm plucker schedule optimization.
struct RosterOptimizationRequestDTO: Codable {
    let estateId: UUID
    let weekStartDate: String
    let totalAvailablePluckers: Int
    let dailyFactoryCapacityKg: Double
    let minimumRestCycleDays: Int?

    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case weekStartDate = "week_start_date"
        case totalAvailablePluckers = "total_available_pluckers"
        case dailyFactoryCapacityKg = "daily_factory_capacity_kg"
        case minimumRestCycleDays = "minimum_rest_cycle_days"
    }
}

/// Field allocation item within a day's plucking schedule.
struct FieldAllocationItemDTO: Codable, Identifiable {
    var id: UUID { fieldId }
    let fieldId: UUID
    let fieldName: String
    let assignedPluckers: Int
    let targetHarvestKg: Double

    enum CodingKeys: String, CodingKey {
        case fieldId = "field_id"
        case fieldName = "field_name"
        case assignedPluckers = "assigned_pluckers"
        case targetHarvestKg = "target_harvest_kg"
    }
}

/// Daily plucking workforce allocation for one working day (Monday - Saturday).
struct DayScheduleDTO: Codable, Identifiable {
    var id: Int { dayIndex }
    let dayIndex: Int
    let dayName: String
    let totalAssignedPluckers: Int
    let estimatedDailyIntakeKg: Double
    let fieldAssignments: [FieldAllocationItemDTO]

    enum CodingKeys: String, CodingKey {
        case dayIndex = "day_index"
        case dayName = "day_name"
        case totalAssignedPluckers = "total_assigned_pluckers"
        case estimatedDailyIntakeKg = "estimated_daily_intake_kg"
        case fieldAssignments = "field_assignments"
    }
}

/// Consolidated 6-day optimized roster returned by the Genetic Algorithm service.
struct RosterOptimizationResponseDTO: Codable, Identifiable {
    var id: String { rosterId }
    let rosterId: String
    let estateId: UUID
    let weekStartDate: String
    let totalPlannedYieldKg: Double
    let workforceUtilizationPct: Double
    let days: [DayScheduleDTO]

    enum CodingKeys: String, CodingKey {
        case rosterId = "roster_id"
        case estateId = "estate_id"
        case weekStartDate = "week_start_date"
        case totalPlannedYieldKg = "total_planned_yield_kg"
        case workforceUtilizationPct = "workforce_utilization_pct"
        case days
    }
}


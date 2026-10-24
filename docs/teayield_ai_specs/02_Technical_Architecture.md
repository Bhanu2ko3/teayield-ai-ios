# Component 2 Specification: System Architecture, Core Data & Cloud Backend Integration
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 20% (Mandatory Component)  
**Status:** Complete Architectural Blueprint  

---

## 1. System Architecture (MVVM + POP + Dependency Injection)

TeaYield AI adheres strictly to the **MVVM (Model-View-ViewModel)** architectural pattern augmented by **Protocol-Oriented Programming (POP)** and **Dependency Injection (DI)**. This decoupled structure ensures 100% testability, modularity, and clean separation of concerns across both mobile and tablet interfaces.

```
+---------------------------------------------------------------------------------------------+
|                                          VIEW LAYER                                         |
|  • iPhone Views: TodayTasksView, LeafScannerView, FieldMapView, SupervisorSettingsView      |
|  • iPad Views: ManagerSplitView, HeatmapCanvasView, YieldAnalyticsView, RosterGeneratorView |
+---------------------------------------------------------------------------------------------+
                                               │
                                               ▼  (Observes State via @Observable / Combine)
+---------------------------------------------------------------------------------------------+
|                                       VIEWMODEL LAYER                                       |
|  • FieldMapViewModel      • LeafScannerViewModel    • YieldAnalyticsViewModel               |
|  • RosterViewModel        • AuthViewModel           • OfflineSyncViewModel                  |
+---------------------------------------------------------------------------------------------+
                                               │
                                               ▼  (Calls Injected Protocol Abstractions)
+---------------------------------------------------------------------------------------------+
|                                  SERVICE / REPOSITORY LAYER                                 |
|  • Protocols: DataRepositoryProtocol, APIServiceProtocol, LocationServiceProtocol           |
|  • Concrete: CoreDataRepository, CloudAPIService, CoreLocationManager                       |
+---------------------------------------------------------------------------------------------+
                                │                              │
                                ▼                              ▼
+-----------------------------------------------+   +-----------------------------------------+
|            LOCAL PERSISTENCE LAYER            |   |          REMOTE CLOUD BACKEND           |
|  • Core Data Container (SQLite Relational DB) |   |  • Python FastAPI AI & GA Engine        |
|  • Secure Enclave Keychain (Tokens)           |   |  • Supabase (PostgreSQL + PostGIS DB)   |
+-----------------------------------------------+   +-----------------------------------------+
```

---

## 2. Core Data Local Entity Relational Schema

To support **100% offline functionality** in remote mountain tea fields with intermittent or zero cellular reception, Core Data manages local relational persistence.

```
+--------------------------+       1:N       +--------------------------+
|      TeaFieldEntity      | ───────────────> |      NDVILogEntity       |
+--------------------------+                 +--------------------------+
| id: UUID (PK)            |                 | id: UUID (PK)            |
| estateId: UUID           |                 | fieldId: UUID (FK)       |
| name: String             |                 | weekStartDate: String    |
| boundaryGeoJSON: String  |                 | ndviValue: Double        |
| areaAcres: Double        |                 | redBandReflectance: Double|
| centroidLatitude: Double |                 | nirBandReflectance: Double|
| centroidLongitude: Double|                 | validPixelRatio: Double  |
| currentNDVI: Double      |                 | timestamp: Date          |
| daysSinceLastHarvest: Int|                 +--------------------------+
| harvestStatus: String    |
| restCycleDays: Int       |
+--------------------------+
             │
             │ 1:N
             ▼
+--------------------------+                 +--------------------------+
|  PluckingSessionEntity   |                 |    UserProfileEntity     |
+--------------------------+                 +--------------------------+
| localLogId: String (PK)  |                 | id: UUID (PK)            |
| fieldId: UUID (FK)       |                 | estateId: UUID           |
| pluckerId: String        |                 | fullName: String         |
| pluckerName: String      |                 | email: String            |
| netWeightKg: Double      |                 | role: String             |
| qualityScore: Double     |                 | phoneNumber: String      |
| qualityGrade: String     |                 | isBiometricEnabled: Bool |
| weighingTimestamp: Date  |                 | lastSyncedAt: Date       |
| gpsLatitude: Double      |                 +--------------------------+
| gpsLongitude: Double     |
| isSynced: Bool           |
| syncedAt: Date?          |
+--------------------------+
```

---

## 3. Biometric Security & Authentication (`LocalAuthentication`)

Sensitive manager features—such as financial labor rosters, auction yield analytics, and worker compensation records—are protected behind biometric authentication.

### Authentication Flow:
1. User attempts to access Estate Manager Executive Suite or view financial rosters.
2. System checks `AuthViewModel`:
   ```swift
   let context = LAContext()
   var error: NSError?
   if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
       context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access financial rosters") { success, error in
           Task { @MainActor in
               if success {
                   self.isAuthenticated = true
               } else {
                   self.showPasscodeFallback()
               }
           }
       }
   }
   ```
3. Fallback: If biometrics fail or are unavailable, the app falls back to evaluating device passcode (`.deviceOwnerAuthentication`).

---

## 4. Python Cloud AI Backend & Supabase Integration (LO3 Requirement)

The iOS client app communicates with a cloud infrastructure consisting of **Supabase (Database/Auth)** and a **Python FastAPI Engine (LSTM AI + Genetic Algorithm)** deployed under `teayield-ai-core`.

### 4.1 REST API Endpoints Specification:

| Endpoint Route | HTTP Method | RBAC Scope | Request Payload / Query | Response DTO | Purpose |
| :--- | :---: | :---: | :--- | :--- | :--- |
| `/api/v1/auth/login` | `POST` | Public | `LoginRequestDTO` | `TokenResponseDTO` | Authenticate credentials and receive Supabase JWT. |
| `/api/v1/auth/me` | `GET` | Authenticated | None (Bearer Token) | `UserProfileDTO` | Retrieve current authenticated user profile. |
| `/api/v1/fields` | `GET` | Manager / Supervisor | `?estate_id=UUID` | `[FieldResponseDTO]` | Fetch estate field polygons, centroids, and NDVI status. |
| `/api/v1/fields` | `POST` | Manager only | `FieldCreateRequestDTO` | `FieldResponseDTO` | Register new field spatial GeoJSON polygon. |
| `/api/v1/fields/{id}/ndvi`| `GET` | Manager / Supervisor | Path: `{id}` | `[NDVILogResponseDTO]` | Retrieve historical Sentinel-2 NDVI time-series logs. |
| `/api/v1/yield/predict` | `POST` | Manager only | `PredictionTriggerDTO` | `YieldPredictionBatchResponseDTO` | Execute 4-week temporal stacked LSTM yield forecast. |
| `/api/v1/roster/optimize`| `POST` | Manager only | `RosterOptimizationRequestDTO` | `RosterOptimizationResponseDTO` | Execute DEAP Genetic Algorithm workforce scheduling. |
| `/api/v1/roster/current` | `GET` | Manager / Supervisor | `?estate_id=UUID` | `RosterOptimizationResponseDTO` | Retrieve active 6-day optimized estate roster matrix. |
| `/api/v1/tasks/daily` | `GET` | Supervisor / Manager | `?estate_id=UUID&day_index=1` | `DailySupervisorTasksResponseDTO` | Retrieve daily field plucking targets and boundaries. |
| `/api/v1/harvest/sync` | `POST` | Supervisor / Manager | `HarvestSyncBatchDTO` | `HarvestSyncResponseDTO` | Batch sync offline weighing logs with GPS validation. |
| `/api/v1/pluckers` | `GET` | Manager / Supervisor | `?estate_id=UUID` | `[PluckerResponseDTO]` | Retrieve active plucker workforce registry. |

---

## 5. Swift Codable Data Transfer Contracts (Client-Server Alignment)

To guarantee type-safe serialization between the Python FastAPI backend (Pydantic v2) and the iOS client (Swift `Codable`), the iOS application utilizes the following data contracts:

```swift
// MARK: - Geospatial Polygon
public struct GeoJSONPolygon: Codable, Sendable {
    public let type: String
    public let coordinates: [[[Double]]]
}

// MARK: - Field DTO
public struct FieldResponseDTO: Codable, Identifiable, Sendable {
    public let id: UUID
    public let estateId: UUID
    public let name: str
    public let areaAcres: Double
    public let boundaryGeoJSON: GeoJSONPolygon
    public let centroidLatitude: Double
    public let centroidLongitude: Double
    public let currentNDVI: Double
    public let daysSinceLastHarvest: Int
    public let harvestStatus: String
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case estateId = "estate_id"
        case name
        case areaAcres = "area_acres"
        case boundaryGeoJSON = "boundary_geojson"
        case centroidLatitude = "centroid_latitude"
        case centroidLongitude = "centroid_longitude"
        case currentNDVI = "current_ndvi"
        case daysSinceLastHarvest = "days_since_last_harvest"
        case harvestStatus = "harvest_status"
        case createdAt = "created_at"
    }
}

// MARK: - Yield Prediction DTOs
public struct PredictionTriggerDTO: Codable, Sendable {
    public let estateId: UUID
    public let targetWeekStart: String
    public let forceSatelliteRefresh: Bool

    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case targetWeekStart = "target_week_start"
        case forceSatelliteRefresh = "force_satellite_refresh"
    }
}

public struct FieldPredictionItemDTO: Codable, Identifiable, Sendable {
    public var id: UUID { fieldId }
    public let fieldId: UUID
    public let fieldName: String
    public let predictedYieldKg: Double
    public let confidenceScore: Double
    public let growthStatus: String
    public let recentNDVI: Double
    public let weatherSummary: WeatherSummaryDTO

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

public struct WeatherSummaryDTO: Codable, Sendable {
    public let cumulativeRainfallMm: Double
    public let meanTempC: Double

    enum CodingKeys: String, CodingKey {
        case cumulativeRainfallMm = "cumulative_rainfall_mm"
        case meanTempC = "mean_temp_c"
    }
}

public struct YieldPredictionBatchResponseDTO: Codable, Sendable {
    public let predictionBatchId: String
    public let targetWeekStart: String
    public let totalPredictedYieldKg: Double
    public let predictions: [FieldPredictionItemDTO]

    enum CodingKeys: String, CodingKey {
        case predictionBatchId = "prediction_batch_id"
        case targetWeekStart = "target_week_start"
        case totalPredictedYieldKg = "total_predicted_yield_kg"
        case predictions
    }
}

// MARK: - Roster Optimization DTOs
public struct RosterOptimizationRequestDTO: Codable, Sendable {
    public let estateId: UUID
    public let weekStartDate: String
    public let totalAvailablePluckers: Int
    public let dailyFactoryCapacityKg: Double
    public let minimumRestCycleDays: Int

    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case weekStartDate = "week_start_date"
        case totalAvailablePluckers = "total_available_pluckers"
        case dailyFactoryCapacityKg = "daily_factory_capacity_kg"
        case minimumRestCycleDays = "minimum_rest_cycle_days"
    }
}

public struct FieldAllocationItemDTO: Codable, Identifiable, Sendable {
    public var id: UUID { fieldId }
    public let fieldId: UUID
    public let fieldName: String
    public let assignedPluckers: Int
    public let targetHarvestKg: Double

    enum CodingKeys: String, CodingKey {
        case fieldId = "field_id"
        case fieldName = "field_name"
        case assignedPluckers = "assigned_pluckers"
        case targetHarvestKg = "target_harvest_kg"
    }
}

public struct DayScheduleDTO: Codable, Identifiable, Sendable {
    public var id: Int { dayIndex }
    public let dayIndex: Int
    public let dayName: String
    public let totalAssignedPluckers: Int
    public let estimatedDailyIntakeKg: Double
    public let fieldAssignments: [FieldAllocationItemDTO]

    enum CodingKeys: String, CodingKey {
        case dayIndex = "day_index"
        case dayName = "day_name"
        case totalAssignedPluckers = "total_assigned_pluckers"
        case estimatedDailyIntakeKg = "estimated_daily_intake_kg"
        case fieldAssignments = "field_assignments"
    }
}

public struct RosterOptimizationResponseDTO: Codable, Sendable {
    public let rosterId: String
    public let estateId: UUID
    public let weekStartDate: String
    public let totalPlannedYieldKg: Double
    public let workforceUtilizationPct: Double
    public let days: [DayScheduleDTO]

    enum CodingKeys: String, CodingKey {
        case rosterId = "roster_id"
        case estateId = "estate_id"
        case weekStartDate = "week_start_date"
        case totalPlannedYieldKg = "total_planned_yield_kg"
        case workforceUtilizationPct = "workforce_utilization_pct"
        case days
    }
}

// MARK: - Offline Harvest Sync DTOs
public struct HarvestLogUploadItemDTO: Codable, Sendable {
    public let localLogId: String
    public let fieldId: UUID
    public let pluckerId: String
    public let pluckerName: String
    public let netWeightKg: Double
    public let coremlLeafQualityScore: Double
    public let qualityGrade: String
    public let weighingTimestamp: Date
    public let gpsLatitude: Double
    public let gpsLongitude: Double

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

public struct HarvestSyncBatchDTO: Codable, Sendable {
    public let syncTimestamp: Date
    public let supervisorId: String
    public let logs: [HarvestLogUploadItemDTO]

    enum CodingKeys: String, CodingKey {
        case syncTimestamp = "sync_timestamp"
        case supervisorId = "supervisor_id"
        case logs
    }
}

public struct HarvestSyncResponseDTO: Codable, Sendable {
    public let processedRecords: Int
    public let failedRecords: Int
    public let status: String
    public let syncedIds: [String]

    enum CodingKeys: String, CodingKey {
        case processedRecords = "processed_records"
        case failedRecords = "failed_records"
        case status
        case syncedIds = "synced_ids"
    }
}

// MARK: - RFC 7807 Error Response
public struct RFC7807ErrorResponse: Codable, Sendable {
    public let statusCode: Int
    public let errorCode: String
    public let message: String
    public let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case errorCode = "error_code"
        case message
        case timestamp
    }
}
```

---

## 6. Offline Synchronization Lifecycle

```
[Field Supervisor Records Weigh-in at Mountain Weighing Shed]
                         │
                         ▼
             Is Cellular Network Available?
             ├── NO  ──> Save to Core Data (`isSynced = false`)
             │            └── Display "Offline Mode: 1 Log Queued" Pill
             │
             └── YES ──> Dispatch immediately to `POST /api/v1/harvest/sync`
                         └── Update Core Data (`isSynced = true, syncedAt = Date()`)
                         │
                         ▼ (When Connection Later Restored)
[NWPathMonitor Detects Cellular or Wi-Fi Connectivity]
                         │
                         ▼
[OfflineSyncManager Queries Core Data for `isSynced == false`]
                         │
                         ▼
[Packages Queued Records into `HarvestSyncBatchDTO`]
                         │
                         ▼
[Calls `POST /api/v1/harvest/sync` with Bearer JWT]
                         │
                         ▼
[Server Validates GPS Coordinates via PostGIS `ST_Contains`]
                         │
                         ▼
[Server Ingests Records & Responds with `synced_ids`]
                         │
                         ▼
[Local Core Data Entities Marked `isSynced = true`]
```

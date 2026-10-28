# Component 2 & LO3 Specification: FastAPI Backend REST API Contract & Networking Architecture
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** Component 2 (20% Mandatory) & Module Learning Outcome 3 (LO3)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Module:** iOS Application Development — BSc (Hons) Computing (BSCCOMP25.1P)  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  
**Status:** Complete API Integration Blueprint  
**Reference Backend Repository:** `~/BSC-computing/research/teayield-ai-core`  

---

## 1. Architectural Scope & Dual-Track Model

The TeaYield AI platform is built upon a decoupled dual-repository architecture. While `teayield-ai-core` hosts the Python 3.11+ FastAPI microservice, Sentinel-2 remote sensing pipeline, stacked LSTM yield forecaster, and DEAP Genetic Algorithm scheduler, `teayield-ai-ios` operates as the native client delivering on-device edge execution.

```
+───────────────────────────────────────────────────────────────────────────────────────────────────+
|                                  TEAYIELD AI ECOSYSTEM TOPOLOGY                                   |
+───────────────────────────────────────────────────────────────────────────────────────────────────+
                                                  │
         ┌────────────────────────────────────────┴────────────────────────────────────────┐
         ▼                                                                                 ▼
+─────────────────────────────────────────+                       +─────────────────────────────────────────+
|            teayield-ai-core             |                       |             teayield-ai-ios             |
|   (Python Backend & Research Core)      |                       |       (Native iOS Mobile Client)        |
+─────────────────────────────────────────+                       +─────────────────────────────────────────+
| • Sentinel-2 Level-2A NDVI Extraction   |                       | • SwiftUI Declarative User Interface    |
| • Open-Meteo Climate Preprocessing      |       REST API        | • SwiftData / Core Data Offline Cache   |
| • Stacked Multivariate LSTM Predictor   | <───────────────────> | • Apple MapKit Interactive Polygons     |
| • DEAP Genetic Algorithm Scheduler      |   (JSON / Bearer)     | • CoreML On-Device Leaf Maturity Vision |
| • FastAPI Asynchronous Microservice    |                       | • Field Weighing Sync Forms & Checkins  |
| • Supabase PostgreSQL 15 + PostGIS      |                       | • iPadOS SplitView Operational Dashboard|
+─────────────────────────────────────────+                       +─────────────────────────────────────────+
```

### Dual-Track Release Readiness:
Under Phase 3 of `teayield-ai-core`, all endpoints have been deployed with deterministic, agro-ecologically realistic contract stubs (`generate_yield_predictions_stub`, `generate_roster_optimization_stub`, `generate_daily_tasks_stub`). This eliminates blocking dependencies: the iOS app can execute end-to-end network requests, parse live JSON, render MapKit polygons, and synchronize offline weighing logs without waiting for offline neural network training.

---

## 2. Authentication & Role-Based Access Control (RBAC)

### 2.1 Supabase JWT Bearer Tokens
All authenticated API requests from the iOS app must transmit a Supabase JWT in the `Authorization` header:
```http
Authorization: Bearer <SUPABASE_JWT_TOKEN>
```
The FastAPI backend validates the token signature, audience, and expiration. Tokens are securely stored in the iOS Keychain via `KeychainService`.

### 2.2 Operational Access Scopes:
- **`estate_manager` (Executive Role - iPad Suite):**
  - Read and register field polygons (`GET/POST /api/v1/fields`).
  - Trigger forward yield predictions (`POST /api/v1/yield/predict`).
  - Execute Genetic Algorithm roster generation (`POST /api/v1/roster/optimize`).
  - Access workforce plucker registries and export official rosters.
- **`field_supervisor` (Operational Role - iPhone Flow):**
  - Read assigned daily tasks and geofenced field polygons (`GET /api/v1/tasks/daily`).
  - Dispatch offline harvest weigh-in logs (`POST /api/v1/harvest/sync`).
  - Restricted from altering field boundaries or running global optimization algorithms (HTTP 403 Forbidden).

---

## 3. Standardized Error Handling (RFC 7807)

The FastAPI backend formats all errors as RFC 7807 problem details JSON payloads:

```json
{
  "status_code": 403,
  "error_code": "INSUFFICIENT_ROLE_PERMISSIONS",
  "message": "Only estate managers can trigger the Genetic Algorithm workforce optimizer.",
  "timestamp": "2026-10-24T10:00:00Z",
  "details": null
}
```

The iOS client decodes these payloads via `RFC7807ErrorResponse` to present contextual user alerts rather than generic network failure dialogs.

---

## 4. Complete REST API Endpoint Catalog

### 4.1 Authentication & Identity Routes
* `POST /api/v1/auth/login`: Accepts `LoginRequestDTO`, returns `TokenResponseDTO` containing JWT token, expiration, and user role.
* `POST /api/v1/auth/register`: Creates new manager or supervisor user.
* `GET /api/v1/auth/me`: Returns profile details for currently authenticated bearer token.

### 4.2 Field Registry & Spatial Polygon Routes
* `GET /api/v1/fields?estate_id={UUID}`: Returns array of `FieldResponseDTO` records with GeoJSON coordinate polygons, centroid coordinates, and vegetative NDVI health.
* `POST /api/v1/fields`: Registers a new field polygon (`FieldCreateRequestDTO`).
* `GET /api/v1/fields/{id}`: Retrieves specific field details.
* `PUT /api/v1/fields/{id}`: Updates field acreage or rest cycle days.
* `DELETE /api/v1/fields/{id}`: Deletes a field record.
* `GET /api/v1/fields/{id}/ndvi`: Fetches historical Sentinel-2 NDVI logs for field.
* `GET /api/v1/fields/{id}/weather`: Fetches historical Open-Meteo weather logs for field.

### 4.3 Predictive Intelligence Routes
* `POST /api/v1/yield/predict`: Triggers temporal LSTM yield forecasting for upcoming week (`PredictionTriggerDTO` ➔ `YieldPredictionBatchResponseDTO`).

### 4.4 Workforce Optimization Routes
* `POST /api/v1/roster/optimize`: Runs DEAP Genetic Algorithm scheduler enforcing trough limits and 7-10 day rest cycles (`RosterOptimizationRequestDTO` ➔ `RosterOptimizationResponseDTO`).
* `GET /api/v1/roster/current?estate_id={UUID}`: Retrieves currently active 6-day workforce schedule matrix.

### 4.5 Field Supervisor Daily Tasks
* `GET /api/v1/tasks/daily?estate_id={UUID}&day_index={1-6}`: Dispatches day-specific assigned fields, plucker headcounts, harvest weight targets, and boundary polygons (`DailySupervisorTasksResponseDTO`).

### 4.6 Harvest Weighing & Offline Store-and-Forward Sync
* `POST /api/v1/harvest/sync`: Ingests queued offline weighing records from SwiftData (`HarvestSyncBatchDTO` ➔ `HarvestSyncResponseDTO`). Validates supervisor GPS coordinates using PostGIS `ST_Contains`.
* `GET /api/v1/harvest/logs`: Retrieves historical weigh-in logs.

### 4.7 Commercial Workforce & Estate Management
* `GET /api/v1/pluckers?estate_id={UUID}`: Lists registered plantation pluckers with daily harvesting quotas.
* `GET /api/v1/estates`: Returns registered tea estate enterprise profiles.

---

## 5. Swift Networking Service Architecture

The iOS networking client is implemented using modern Swift concurrency (`async/await`) and protocol-based dependency injection.

```swift
import Foundation

public protocol APIServiceProtocol: Sendable {
    func login(credentials: LoginRequestDTO) async throws -> TokenResponseDTO
    func fetchFields(estateId: UUID) async throws -> [FieldResponseDTO]
    func registerField(payload: FieldCreateRequestDTO) async throws -> FieldResponseDTO
    func predictYield(payload: PredictionTriggerDTO) async throws -> YieldPredictionBatchResponseDTO
    func optimizeRoster(payload: RosterOptimizationRequestDTO) async throws -> RosterOptimizationResponseDTO
    func fetchCurrentRoster(estateId: UUID) async throws -> RosterOptimizationResponseDTO
    func fetchDailyTasks(estateId: UUID, dayIndex: Int) async throws -> DailySupervisorTasksResponseDTO
    func syncHarvestLogs(batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO
}

public actor CloudAPIService: APIServiceProtocol {
    private let session: URLSession
    private let baseURL: URL
    private let keychain: KeychainServiceProtocol

    public init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        session: URLSession = .shared,
        keychain: KeychainServiceProtocol = KeychainService.shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.keychain = keychain
    }

    private func createAuthorizedRequest(endpoint: String, method: String) throws -> URLRequest {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let token = keychain.retrieveToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    public func fetchDailyTasks(estateId: UUID, dayIndex: Int) async throws -> DailySupervisorTasksResponseDTO {
        var request = try createAuthorizedRequest(
            endpoint: "tasks/daily?estate_id=\(estateId.uuidString)&day_index=\(dayIndex)",
            method: "GET"
        )
        let (data, response) = try await session.data(for: request)
        try validateHTTPResponse(response, data: data)
        return try JSONDecoder.iso8601Decoder.decode(DailySupervisorTasksResponseDTO.self, from: data)
    }

    public func syncHarvestLogs(batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO {
        var request = try createAuthorizedRequest(endpoint: "harvest/sync", method: "POST")
        request.httpBody = try JSONEncoder.iso8601Encoder.encode(batch)
        let (data, response) = try await session.data(for: request)
        try validateHTTPResponse(response, data: data)
        return try JSONDecoder.iso8601Decoder.decode(HarvestSyncResponseDTO.self, from: data)
    }

    private func validateHTTPResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorPayload = try? JSONDecoder.iso8601Decoder.decode(RFC7807ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorPayload)
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
```

---

## 6. Real-World Domain Seed Reference (Nuwara Eliya Pedro Estate)

All mock fixtures, offline unit tests, and live simulator runs are seeded with production tea estate telemetry:

- **Estate Identifier:** `3b241101-5231-4822-a982-f87c126d4001`
- **Estate Designation:** *Nuwara Eliya High-Grown Estate* (Pedro Estate, Upper Division)
- **Geographical Boundary Fields:**
  1. `Upper Division Block A` (ID: `7c9e6679-7425-40de-944b-e07fc1f90ae7` | Area: 12.5 Ac | Peak NDVI: 0.820 | Status: READY)
  2. `Middle Valley Block B` (ID: `8d1f7780-8536-41ef-055c-f18fd2a01bf8` | Area: 15.0 Ac | NDVI: 0.740 | Status: GROWING)
  3. `Lower Ravine Block C` (ID: `9e2a8891-9647-42f0-166d-a29fe3b12ca9` | Area: 9.8 Ac | Rest NDVI: 0.580 | Status: RESTING)
  4. `High Peak Ridge Block D` (ID: `a34b9902-0758-4301-277e-b30af4c23db0` | Area: 18.2 Ac | NDVI: 0.690 | Status: GROWING)
- **Workforce Sample Pluckers:**
  - `EMP-4012`: K. Meenakshi (Target: 27.5 kg/day)
  - `EMP-4013`: S. Kamalasani (Target: 24.8 kg/day)
  - `EMP-4014`: R. Thavamani (Target: 26.2 kg/day)
  - `EMP-4016`: P. Vijaya (Target: 28.5 kg/day)

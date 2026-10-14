# Component 2 Specification: System Architecture, Core Data & Cloud Backend Integration
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 20% (Mandatory Component)  
**Status:** Complete Architectural Blueprint  

---

## 1. System Architecture (MVVM + POP + Dependency Injection)

TeaYield AI adheres strictly to the **MVVM (Model-View-ViewModel)** architectural pattern augmented by **Protocol-Oriented Programming (POP)** and **Dependency Injection (DI)**. This decoupled structure ensures 100% testability, modularity, and clean separation of concerns.

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

To support **100% offline functionality** in remote tea fields, Core Data manages local relational persistence.

```
+--------------------------+       1:N       +--------------------------+
|      TeaFieldEntity      | ───────────────> |      NDVILogEntity       |
+--------------------------+                 +--------------------------+
| id: UUID (PK)            |                 | id: UUID (PK)            |
| name: String             |                 | fieldId: UUID (FK)       |
| boundaryGeoJSON: String  |                 | ndviValue: Double        |
| areaAcres: Double        |                 | redBand: Double          |
| targetCapacityKg: Double |                 | nirBand: Double          |
| restCycleDays: Int       |                 | timestamp: Date          |
+--------------------------+                 +--------------------------+
             │
             │ 1:N
             ▼
+--------------------------+                 +--------------------------+
|  PluckingSessionEntity   |                 |    UserProfileEntity     |
+--------------------------+                 +--------------------------+
| id: UUID (PK)            |                 | id: UUID (PK)            |
| fieldId: UUID (FK)       |                 | name: String             |
| harvestedKg: Double      |                 | email: String            |
| qualityScore: Double     |                 | role: String (Manager)   |
| supervisorId: String     |                 | isBiometricEnabled: Bool |
| timestamp: Date          |                 +--------------------------+
| isSynced: Bool           |
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

The iOS client app communicates with a cloud infrastructure consisting of **Supabase (Database/Auth)** and a **Python FastAPI Engine (LSTM AI + Genetic Algorithm)**.

### REST API Endpoints Specification:

| Endpoint | Method | Purpose | Payload / Parameters | Response |
| :--- | :---: | :--- | :--- | :--- |
| `/api/v1/auth/login` | POST | Manager / Supervisor authentication | `{ email, password }` | `{ token, userRole, estateId }` |
| `/api/v1/fields` | GET/POST | Spatial polygon fields fetch & registration | `GeoJSON Polygon Payload` | `[TeaFieldDTO]` |
| `/api/v1/sync/sentinel` | POST | Triggers Sentinel-2 NDVI satellite fetch | `{ fieldId, startDate, endDate }` | `{ fieldId, ndviValue, timestamp }` |
| `/api/v1/predict/yield` | POST | Triggers PyTorch LSTM temporal yield forecast | `{ estateId, targetWeek }` | `{ predictions: [{ fieldId, predictedKg }] }` |
| `/api/v1/optimize/roster`| POST | Triggers DEAP Genetic Algorithm scheduler | `{ estateId, availableWorkers, shiftDays }` | `{ roster: [{ day, fieldId, assignedWorkers }] }` |

---

## 5. Offline Synchronization Lifecycle

```
[User logs Plucking Session in Remote Field]
                   │
                   ▼
       Is Network Available?
       ├── NO  ──> Save to Core Data (`isSynced = false`) ──> Show "Cached Offline" Badge
       └── YES ──> POST `/api/v1/sessions` ──> Update Core Data (`isSynced = true`)
                   │
                   ▼ (When Connection Restored)
    [Background Sync Engine (NWPathMonitor)] ──> Pushes all `isSynced == false` records to Supabase
```

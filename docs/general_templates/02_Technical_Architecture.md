# Component 2 Specification: System Architecture, Core Data & Backend Integration
**Target Weightage:** 20% (Mandatory Component)  
**Status:** Architecture Blueprint  

---

## 1. System Architecture (MVVM + POP)

```
+-------------------------------------------------------------------------+
|                               VIEW LAYER                                |
| (SwiftUI Views: DashboardView, DetailView, SettingsView, LoginView)     |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                             VIEWMODEL LAYER                             |
| (@Observable / ObservableObject: MainVM, AuthVM, LocationVM)             |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                         SERVICE / REPOSITORY LAYER                      |
| (Protocols: AuthServiceProtocol, DataRepositoryProtocol, APIService)    |
+-------------------------------------------------------------------------+
                    |                               |
                    v                               v
+-----------------------------------+   +---------------------------------+
|       LOCAL PERSISTENCE LAYER      |   |       REMOTE BACKEND LAYER      |
|  (Core Data Stack / Persistence)  |   |  (Firebase / REST API Service)  |
+-----------------------------------+   +---------------------------------+
```

---

## 2. Core Data Entity Schema
- **Entity 1: `UserProfile`**
  - `id`: UUID (Primary Key)
  - `name`: String
  - `email`: String
  - `createdAt`: Date
  - `isBiometricEnabled`: Boolean

- **Entity 2: `ItemRecord`**
  - `id`: UUID
  - `title`: String
  - `details`: String
  - `category`: String
  - `timestamp`: Date
  - `latitude`: Double
  - `longitude`: Double

---

## 3. Biometric Authentication Flow (LocalAuthentication)
1. User opens secured view or app launch.
2. System checks `LAContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`.
3. Triggers Face ID / Touch ID prompt with fallback to device passcode.
4. On success -> Updates `AuthViewModel.isAuthenticated = true`.

---

## 4. External API / Backend Sync (LO3 Requirement)
- **Backend Type:** Firebase Firestore / REST API
- **Endpoints / Collections:**
  - GET `/api/data` -> Fetches external sync payload.
  - POST `/api/sync` -> Pushes offline cached records to cloud.
- **Offline Strategy:** Core Data acts as single source of truth; sync service pushes/pulls changes when network connection is restored.

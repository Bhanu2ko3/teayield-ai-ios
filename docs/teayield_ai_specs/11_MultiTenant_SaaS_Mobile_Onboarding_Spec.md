# Specification 11: Multi-Tenant SaaS Mobile Client Onboarding & Progressive Lifecycle Specification
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform (iOS Companion Client)  
**Affiliation:** Coventry University (UK) & National Institute of Business Management (Sri Lanka)  
**Programme:** BSc (Hons) in Computing — iOS Application Development (BSCCOMP25.1P)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Document Status:** Complete Engineering Specification & Implementation Plan  
**Version:** 1.0.0  
**Companion Backend Specification:** `teayield-ai-core/docs/teayield_core_specs/09_Multi_Tenant_SaaS_Onboarding_Upgrade_Spec.md`

---

## 1. Executive Context & Architectural Objectives

### 1.1 Transition to Autonomous Commercial Multi-Tenancy
The foundational iterations of the TeaYield AI iOS client operated against static demonstration data seeded under a single Nuwara Eliya plantation (Pedro Estate). While sufficient for initial MVP evaluation, production deployment on the Apple App Store requires a self-serve multi-tenant architecture. 

Under this model, any commercial plantation enterprise across Sri Lanka (High-grown, Mid-grown, or Low-grown districts) can download the mobile application, complete an autonomous thirty-second manager signup, configure physical estate parameters, map spatial field polygons, and provision subordinate field supervisors without backend developer assistance or manual database intervention.

### 1.2 Core Architectural Principles
1. **Zero-Friction Entry:** Unauthenticated users register with basic profile attributes (< 30 seconds) without early spatial or agronomic barriers.
2. **Prior Ingestion Gating:** Downstream deep learning models (multivariate temporal LSTM) and operations-research schedulers (DEAP Genetic Algorithm) strictly require mathematical priors (elevation, acreage, and factory intake withering limits). These are captured during mandatory onboarding before granting access to operational dashboards.
3. **Decoupled Role Hierarchy:** Strict separation between Tenant Administrators (`estate_manager`) and Operational Delegates (`field_supervisor`).
4. **Xcode 14.3.1 / iOS 16.4 SDK Baseline:** All SwiftUI views and ViewModels strictly maintain backward compatibility using `@MainActor`, `final class ...ViewModel: ObservableObject`, and `@Published` properties, avoiding iOS 17-only observation macros.
5. **Strict Exclusion of Decorative Emojis:** Conforming to corporate software engineering standards, all UI labels, icons, code docstrings, and error alerts utilize native SF Symbols and clean typography.

---

## 2. Multi-Tenant State Machine & Routing Topology

The mobile application acts as a finite state machine governed by the authenticated user's profile metadata retrieved from `GET /api/v1/auth/me`.

```
                                 [Application Launch]
                                           │
                                           ▼
                                [RootView Coordinator]
                                           │
                 ┌─────────────────────────┴─────────────────────────┐
                 │                                                   │
         [!isAuthenticated]                                   [isAuthenticated]
                 │                                                   │
                 ▼                                                   ▼
         [Login / SignUp View]                            [Evaluate Profile Metadata]
         (Toggle: Sign In vs.                                        │
          Manager Registration)             ┌────────────────────────┼────────────────────────┐
                                            │                        │                        │
                                            ▼                        ▼                        ▼
                                   [must_change_password]    [estate_id == nil]      [Fully Onboarded]
                                            │                        │                        │
                                            ▼                        ▼                        ▼
                                 [ForcePasswordChangeView]  [EstateOnboardingView]   [Operational Shell]
                                 (Rotate Temporary Creds)   (Ingest Prior Priors)     │
                                            │                        │                ├─ iPhone Supervisor
                                            │                        │                │  (4-Tab Flow)
                                            ▼                        ▼                └─ iPad Manager
                                      [Update Token]           [Bind Estate]             (NavigationSplitView)
```

---

## 3. Component Breakdown & Detailed Implementation Plan

---

### Component 1: Manager Self-Service Registration Flow (`SignUpView`)

#### 1.1 Objective:
Allow prospective estate managers to register a new tenant account with zero friction directly from the iOS login surface.

#### 1.2 UI & UX Specification:
- **Surface:** Embedded within `LoginView` via a segmented control or navigation toggle: `"Sign In"` vs `"Create Manager Account"`.
- **Form Fields:**
  - Full Legal Name (`TextField`, autocapitalization words).
  - Corporate Business Email (`TextField`, keyboardType emailAddress, lowercase).
  - Account Password (`SecureField`, min 8 characters, visibility toggle).
  - Mobile Contact Number (`TextField`, keyboardType phonePad, optional).
- **Client Validation:**
  - Real-time regex email syntax check.
  - Password strength verification (minimum 8 characters).
  - Clear visual feedback for validation errors.
- **Service Integration:**
  - Invokes `apiService.signupManager(request: ManagerSignUpRequestDTO)`.
  - On HTTP 201 Created: Stores access token in hardware Keychain via `KeychainHelper`, updates `AuthService.isAuthenticated = true`, and sets `AuthService.currentUser` with `estateId = nil`.
  - Transitions user state directly to Component 2 (Estate Onboarding Wizard).

---

### Component 2: Estate Onboarding Wizard Flow (`EstateOnboardingView`)

#### 2.1 Objective:
Capture mandatory agro-ecological and physical manufacturing limits required by the cloud LSTM yield predictor and Genetic Algorithm before unlocking dashboard access.

#### 2.2 Mathematical Priors & Form Inputs:
1. **Estate Commercial Designation:** Text input (e.g. `Great Western Valley Estate`).
2. **Agro-Ecological District:** Native `Picker` restricted to authorized Sri Lankan tea cultivation zones:
   - `Nuwara Eliya` (High-Grown, premium elevation)
   - `Badulla` / `Uva` (High-to-Mid Grown, dry wind exposure)
   - `Kandy` (Mid-Grown)
   - `Matale` (Mid-Grown)
   - `Ratnapura` (Low-Grown Sabaragamuwa)
   - `Kegalle` (Low-Grown)
   - `Galle` (Low-Grown Southern)
   - `Matara` (Low-Grown Southern)
3. **Mean Plantation Elevation:** Numeric stepper or slider bounded between 50m and 2,600m (critical for Sentinel-2 atmospheric correction and temperature lapse-rate calculation).
4. **Total Surveyed Landholding (Acres):** Decimal input bounded between 1.0 and 50,000.0 acres.
5. **Daily Factory Withering Capacity Limit ($C_{\text{factory}}$ in kg):** Decimal input representing maximum leaf throughput of withering troughs (used as the hard quadratic penalty barrier in Genetic Algorithm optimization).

#### 2.3 ViewModel & State Handling:
- **Class:** `final class EstateOnboardingViewModel: ObservableObject, @MainActor`
- **Published Properties:**
  - `@Published var estateName: String`
  - `@Published var selectedDistrict: String`
  - `@Published var elevationInput: String`
  - `@Published var totalAcresInput: String`
  - `@Published var factoryCapacityInput: String`
  - `@Published var isSubmitting: Bool`
  - `@Published var errorMessage: String?`
- **Execution:**
  - Dispatches `POST /api/v1/estates/onboard` via `apiService.onboardEstate(request:)`.
  - On HTTP 201 Created: Updates `currentUser.estateId`, updates Keychain user cache, and triggers haptic success feedback (`HapticFeedback.success()`).
  - `RootView` automatically detects `estate_id != nil` and navigates into the manager executive suite.

---

### Component 3: Mandatory Credential Rotation Flow (`ForcePasswordChangeView`)

#### 3.1 Objective:
Enforce password rotation for subordinate supervisors logging in with manager-issued temporary passwords before exposing field data.

#### 3.2 UI & UX Specification:
- **Presentation:** Full-screen modal or non-dismissible card triggered when `currentUser.mustChangePassword == true`.
- **Form Fields:**
  - Current Temporary Password (`SecureField`).
  - New Permanent Password (`SecureField`, min 8 characters).
  - Confirm New Password (`SecureField`).
- **Validation Rules:**
  - `newPassword.count >= 8`.
  - `newPassword != currentPassword`.
  - `newPassword == confirmPassword`.
- **Service Integration:**
  - Dispatches `POST /api/v1/auth/change-password` via `apiService.changePassword(request:)`.
  - On HTTP 200 OK: Updates `currentUser.mustChangePassword = false`, stores updated session in Keychain, and dismisses view to grant full supervisor dashboard access.

---

### Component 4: Team Provisioning & Supervisor Delegation (`InviteSupervisorSheetView`)

#### 4.1 Objective:
Empower estate managers to autonomously add and provision subordinate field supervisors for their specific estate without external database assistance.

#### 4.2 Presentation & Entry Point:
- Embedded in `ManagerOverviewView` and `ManagerExecutiveSuiteView` under a dedicated `"Team & Delegation"` administration section.
- Presented as a native sheet with dismiss and submit toolbar actions.

#### 4.3 Form Inputs & Validation:
- Supervisor Full Legal Name (`TextField`).
- Supervisor Login Email Address (`TextField`, emailAddress keyboard).
- Initial Temporary Password (`SecureField` with quick random password generation utility).
- Field Radio / Contact Phone Number (`TextField`, phonePad, optional).

#### 4.4 Service Integration:
- Dispatches `POST /api/v1/auth/invite-supervisor` via `apiService.inviteSupervisor(request:)`.
- Backend links created supervisor to the calling manager's `estate_id` and sets `must_change_password = true`.
- Displays confirmation dialog with copyable credential summary for field dispatch.

---

### Component 5: RootView State Machine Enhancement

#### 5.1 Updates to `TeaYieldAI/Views/Root/RootView.swift`:
Replace rigid boolean checks with progressive lifecycle evaluation:

```swift
Group {
    if !hasCompletedOnboarding {
        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
    } else if !authService.isAuthenticated {
        LoginView(viewModel: AuthViewModel(authService: container.authService))
    } else if let user = authService.currentUser, user.mustChangePassword {
        ForcePasswordChangeView(authService: container.authService, apiService: container.apiService)
    } else if let user = authService.currentUser, user.isManager && (user.estateId == nil || user.estateId == UUID(uuidString: "00000000-0000-0000-0000-000000000000")) {
        EstateOnboardingView(authService: container.authService, apiService: container.apiService)
    } else if horizontalSizeClass == .regular {
        ManagerExecutiveSuiteView(container: container)
    } else if authService.currentUser?.isManager == true {
        ManagerOverviewView(container: container)
    } else {
        SupervisorMainTabView(container: container)
    }
}
```

---

## 4. Planned File Structure & Artifact Manifest

```
TeaYieldAI/
├── ViewModels/
│   ├── AuthViewModel.swift                     [ENHANCED: Support signup toggle & validation]
│   ├── EstateOnboardingViewModel.swift         [NEW: Wizard validation & API dispatch]
│   ├── ForcePasswordChangeViewModel.swift      [NEW: Credential rotation state handling]
│   └── InviteSupervisorViewModel.swift         [NEW: Team delegation logic & credential gen]
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift                     [ENHANCED: Segmented Sign In / Manager Sign Up]
│   │   └── ForcePasswordChangeView.swift       [NEW: Mandatory password rotation screen]
│   ├── Onboarding/
│   │   ├── EstateOnboardingView.swift          [NEW: 5-parameter estate onboarding wizard]
│   │   └── Components/
│   │       └── DistrictPickerField.swift       [NEW: Agro-ecological zone selection control]
│   ├── Manager/
│   │   └── Components/
│   │       └── InviteSupervisorSheetView.swift [NEW: Autonomous staff invitation sheet]
│   └── Root/
│       └── RootView.swift                      [ENHANCED: Progressive state machine routing]
└── TeaYieldAITests/
    └── Tests/
        └── MultiTenantOnboardingTests.swift    [NEW: Swift Testing suite for full lifecycle]
```

---

## 5. Security Invariants & Defensive Handling

1. **Token Hygiene:** Cleartext passwords are never retained in application memory after request execution. Bearer tokens reside exclusively in hardware iOS Keychain (`kSecClassGenericPassword`).
2. **Precondition Gating:** Field supervisors cannot execute harvest weigh-ins until credential rotation succeeds (`mustChangePassword == false`).
3. **Cross-Tenant Guardrails:** Network query parameters always include the validated `estate_id` derived from the server-validated JWT payload.
4. **RFC 7807 Problem Details:** If onboarding encounters conflict (e.g. HTTP 409 duplicate estate name) or validation failure (HTTP 422), errors decode into localized, actionable user alerts.

---

## 6. Verification & Automated Quality Assurance Matrix

| Test ID | Test Scenario | Expected Outcome | Framework |
| :--- | :--- | :--- | :--- |
| `TEST-MTO-UI-01` | Manager switches between Sign In and Sign Up tabs | UI state toggles form fields cleanly; inputs reset | Swift Testing (`@Test`) |
| `TEST-MTO-UI-02` | Manager submits valid registration payload | Mock API called; token saved; `estate_id == nil` | Swift Testing (`@Test`) |
| `TEST-MTO-UI-03` | `RootView` intercepts `estate_id == nil` | Renders `EstateOnboardingView` automatically | UI & View Test |
| `TEST-MTO-UI-04` | Manager submits estate parameters | `POST /api/v1/estates/onboard` succeeds; dashboard unlocks | Swift Testing (`@Test`) |
| `TEST-MTO-UI-05` | Supervisor logs in with `mustChangePassword = true` | `ForcePasswordChangeView` prevents dashboard access | Swift Testing (`@Test`) |
| `TEST-MTO-UI-06` | Supervisor successfully rotates temporary password | `must_change_password` set to `false`; shell unlocks | Swift Testing (`@Test`) |
| `TEST-MTO-UI-07` | Manager invites subordinate supervisor | API receives valid payload; temporary password confirmed | Swift Testing (`@Test`) |

---

## 7. Definition of Done (DoD)

1. Specification document approved and committed under `docs/teayield_ai_specs/11_MultiTenant_SaaS_Mobile_Onboarding_Spec.md`.
2. All new views implement SF Symbols with zero decorative emojis.
3. Every public struct, class, and method carries standard triple-slash (`///`) docstrings explaining agronomic and operational context.
4. 100% VoiceOver accessibility labels and hints configured on all onboarding and password fields.
5. Codebase compiles with zero warnings on Xcode 14.3.1 (iOS 16.4 SDK) baseline.

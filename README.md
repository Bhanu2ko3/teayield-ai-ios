# TeaYield AI iOS — Precision Tea Yield Prediction & Plucking Schedule Optimization Client

[![Academic Level](https://img.shields.io/badge/ACADEMIC%20LEVEL-LEVEL%206%20(COVENTRY%20UK)-0078D4?style=for-the-badge)](https://www.coventry.ac.uk/)
[![Module](https://img.shields.io/badge/MODULE-IOS%20APPLICATION%20DEVELOPMENT-7B1FA2?style=for-the-badge)](https://www.nibm.lk/)
[![Target Grade](https://img.shields.io/badge/TARGET%20GRADE-A%2B%20DISTINCTION%20(100%25)-2EA44F?style=for-the-badge)](docs/project_documents/COBSCCOMP251P-082_Final_Report.md)
[![Release Version](https://img.shields.io/badge/RELEASE-v1.0.0%20FINAL-brightgreen?style=for-the-badge)](https://github.com/Bhanu2ko3/teayield-ai-ios/releases/tag/v1.0.0)
[![Final Graded Commit](https://img.shields.io/badge/COMMIT%20HASH-ab16fe8-blue?style=for-the-badge)](https://github.com/Bhanu2ko3/teayield-ai-ios/commit/ab16fe8)
[![Architecture](https://img.shields.io/badge/ARCHITECTURE-MVVM%20%2B%20POP%20%2B%20DI-FF6F00?style=for-the-badge)](docs/teayield_ai_specs/02_Technical_Architecture.md)
[![AI Edge Core](https://img.shields.io/badge/EDGE%20AI-COREML%20%2B%20VISION%2060FPS-1976D2?style=for-the-badge)](docs/teayield_ai_specs/03_Advanced_SDK_Spec.md)
[![Geospatial](https://img.shields.io/badge/GEOSPATIAL-MAPKIT%20%2B%20GEOFENCING-E65100?style=for-the-badge)](docs/teayield_ai_specs/03_Advanced_SDK_Spec.md)
[![Testing Framework](https://img.shields.io/badge/TESTING-SWIFT%20TESTING%20(17%20SUITES)-orange?style=for-the-badge)](TeaYieldAITests/)
[![License](https://img.shields.io/badge/LICENSE-MIT-F1C40F?style=for-the-badge)](LICENSE)

> **Target Domain:** Regional Plantation Companies (RPCs) & Sri Lankan Tea Industry  
> **Module:** iOS Application Development (Level 6, Batch BSCCOMP25.1P)  
> **Awarding Body:** Coventry University (UK) delivered at National Institute of Business Management (NIBM)  
> **Student:** A G K M B M BANDARA (COBSCOMP251P-082 | Coventry ID: 16604375)  
> **Final Release Status:** Complete Version 1.0.0 Production Release (`ab16fe8`)  
> **Target Standard:** First-Class Honours / A+ Distinction (100% Marks)  
> **Architectural Topology:** Dual-Repository Ecosystem (`teayield-ai-core` + `teayield-ai-ios`)  
> **Primary Technology Stack:** Swift 5.9+ | SwiftUI Declarative UI | SwiftData / Core Data | MapKit & CoreLocation | On-Device CoreML Vision | Apple Charts | WidgetKit  

---

## Executive Summary & Research Business Case

Sri Lankan commercial tea plantations (such as Pedro Estate in Nuwara Eliya) represent a cornerstone of the national agricultural economy, yet operational harvest planning across expansive, high-altitude mountain plantations remains governed by manual heuristics and visual inspection.

This operational reliance introduces three chronic systemic vulnerabilities:
1. **Labor Misallocation:** Plucking gangs are disproportionately deployed to low-yield fields, elevating unit production costs while high-yield plots experience vegetative over-maturation.
2. **Factory Withering Bottlenecks:** Uncoordinated harvest flushes exceed daily factory withering trough intake quotas, causing leaf spoilage and commercial downgrade.
3. **Quality Dilution at Weighing Checkpoints:** Piece-rate plucker compensation incentivizes the plucking of coarse foliage and mature stalks, diluting Ceylon tea auction value.

TeaYield AI iOS eliminates these bottlenecks by coupling cloud intelligence from `teayield-ai-core` (Sentinel-2 NDVI remote sensing, Open-Meteo meteorological reanalysis, stacked LSTM yield prediction, and DEAP Genetic Algorithm workforce scheduling) with an offline-resilient native Apple client running on-device edge AI.

---

## Live Cloud API & Evaluation Gateways

The application communicates with the deployed cloud backend or local edge development server:

* **Live Cloud API Gateway:** `https://teayield-api.codebroai.com/api/v1` (Cloudflare Edge SSL + Oracle Cloud Infrastructure)
* **Local Loopback API:** `http://127.0.0.1:8000/api/v1`
* **Evaluation Credentials:** Evaluation access credentials for Estate Manager and Field Supervisor test profiles are documented in Section 1.3 of the Coursework Final Report (`docs/project_documents/COBSCCOMP251P-082_Final_Report.md`) and LMS submission portal.


---

## The Dual-Track API-First Architectural Pattern

This system strictly decouples the high-performance cloud intelligence core from the edge native mobile client, enforcing an **Agile API-First & Dual-Track Execution Model**:

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
| • Open-Meteo Climate Preprocessing      |       REST API        | • Core Data Offline Relational Cache    |
| • Stacked Multivariate LSTM Predictor   | <───────────────────> | • Apple MapKit Vector Polygons          |
| • DEAP Genetic Algorithm Scheduler      |   (JSON / Bearer)     | • CoreML On-Device Leaf Maturity Vision |
| • FastAPI Asynchronous Microservice    |                       | • Field Weighing Sync & Offline Queue   |
| • Supabase PostgreSQL 15 + PostGIS      |                       | • iPadOS SplitView Executive Dashboard  |
+─────────────────────────────────────────+                       +─────────────────────────────────────────+
```

---

## Coursework Assessment Architecture (100% Weightage)

This repository fulfills all six assessment components of the NIBM iOS Application Development module (BSCCOMP25.1P):

```
+-----------------------------------------------------------------------------------+
| Component 1: Prototype & MVP Approval (10%)                 [MANDATORY - 100%]    |
| Component 2: MVP Implementation, External API & Viva (20%)  [MANDATORY - 100%]    |
| Component 3: Advanced iOS SDK - On-Device (20%)             [MANDATORY - 100%]    |
| Component 4: Unit Tests, Accessibility & Docs (15%)         [ELECTIVE  - 100%]    |
| Component 5: Above & Beyond - iPad & Architecture (25%)    [ELECTIVE  - 100%]    |
| Component 6: In-Class Tutorial 4 - PlayHubApp (10%)         [ELECTIVE  - 100%]    |
+-----------------------------------------------------------------------------------+
```

### Component 1 — Proposal & High-Fidelity UI/UX Prototype (10% - Mandatory)
- **Problem Statement & USP:** Zero-IoT satellite agritech vs manual visual heuristics.
- **UI/UX Deliverable:** High-fidelity 10-screen Figma prototype strictly following Apple Human Interface Guidelines (HIG), supporting dynamic light/dark mode and dual size-class flows.
- **Figma Prototype Link:** [TeaYield AI — High-Fidelity iOS & iPadOS Prototype](https://www.figma.com/design/wy9cRSQbIl3aDBLoRePju0/TeaYield-AI-%E2%80%94-High-Fidelity-iOS---iPadOS-Prototype?node-id=0-1&t=M4kyhtmOd7MU3YQ6-1)

### Component 2 — MVP Implementation, External API & Live Viva (20% - Mandatory)
- **All 3 Platform Features Implemented:**
  1. **Core Data Local Storage:** Relational persistence (`TeaFieldEntity`, `NDVILogEntity`, `HarvestLogEntity`) with thread-safe `newBackgroundContext()` saves preventing UI stutter.
  2. **Biometric Security:** Face ID / Touch ID hardware authentication via `LocalAuthentication` with passcode fallback and Secure Enclave Keychain token storage (`KeychainHelper`).
  3. **Local Push Notifications:** Managed via `NotificationManager` for geofenced field arrival alerts.
- **External Integration (LO3):** Asynchronous REST networking (`CloudAPIService`) connecting to FastAPI backend with RFC 7807 problem details error decoding.
- **Store-and-Forward Sync:** `OfflineSyncManager` powered by `NWPathMonitor` for automatic network restoration sync with idempotent client UUIDs (`localLogId`).

### Component 3 — Advanced iOS SDK (100% On-Device) (20% - Mandatory)
- **Feature 1 (On-Device Edge AI):** `VNCoreMLModel` executing `TeaShootClassifier_v2.mlmodel` (`MobileNetV3-Small`, 2.5M params, 5.79 MB) on Apple Silicon Neural Engine in `< 12 ms` at 60fps. Evaluates "Two Leaves and a Bud" against Sri Lanka Tea Board 85% export standard. Strictly zero cloud AI calls.
- **Feature 2 (Geospatial & Geofencing):** MapKit spatial vector field polygon overlays (`MKPolygon`) color-coded by vegetative NDVI health and low-power background circular geofencing (`CLCircularRegion`) alerting supervisors upon field entry.

### Component 4 — Swift Testing, Accessibility & Documentation (15%)
- **Modern Apple Swift Testing (`import Testing`):** Macro-driven test suites (`@Suite`, `@Test`, `#expect`) across 17+ test files covering ViewModels, Core Data repositories, DTOs, GeoJSON parsing, and offline sync.
- **100% VoiceOver Accessibility:** Annotated interactive elements with descriptive `.accessibilityLabel`, `.accessibilityHint`, and `.accessibilityTraits`. Dynamic Type font scaling across all semantic tokens.
- **4-Page Structured Report:** Complete academic report document ([COBSCCOMP251P-082_Final_Report.md](docs/project_documents/COBSCCOMP251P-082_Final_Report.md)) covering architecture, challenges, LO1–LO4 reflection, and permitted non-code LLM log.

### Component 5 — Above & Beyond (25% - Maximum Weightage)
- **Multi-Device Adaptation (LO1):** iPhone compact single-column supervisor flow vs iPad regular desktop-class 3-column `NavigationSplitView` executive suite (`ManagerExecutiveSuiteView`).
- **Apple Charts Framework:** Native `BarMark` and `LineMark` visualizations comparing 7-day predicted yields against verified weigh-ins and factory intake capacity gauges.
- **Autonomous Multi-Tenant SaaS Onboarding:** Self-service registration wizard (`EstateOnboardingView`) ingesting elevation, acreage, and intake capacity, with mandatory password rotation (`ForcePasswordChangeView`).
- **PDF Export & WidgetKit:** Native on-device printable roster PDF generator (`RosterPDFGenerator.swift`) and iOS Home Screen Widget (`TeaYieldAIWidget`).
- **UI Polish:** Matched geometry transitions (`.matchedGeometryEffect`) and tactile micro-haptics (`HapticFeedback.swift`).

### Component 6 — In-Class Tutorial 4 "PlayHubApp" (10%)
- Standalone laboratory coursework project submitted via `COBSCOMP251P-082_Bandara_Tutorial4.zip`.

---

## Repository Architecture & Codebase Structure

```
teayield-ai-ios/
├── TeaYieldAI/                                  # Main iOS Application Target
│   ├── App/                                     # TeaYieldAIApp Lifecycle & AppContainer DI
│   ├── Core/                                    # Foundational System Infrastructure
│   │   ├── DI/AppContainer.swift                # Dependency Injection Container & Protocols
│   │   ├── Network/                             # URLSession REST Client, APIEndpoint, NetworkError
│   │   ├── Notifications/                       # Local Notification Manager (Geofence Alerts)
│   │   ├── Security/                            # LocalAuthentication Face ID & Keychain Helper
│   │   └── Utilities/                           # AppTheme, GeoJSONParser, RosterPDFGenerator, Haptics
│   ├── Models/                                  # Data Entities
│   │   ├── CoreML/                              # TeaShootClassifier_v2.mlmodel (MobileNetV3)
│   │   ├── Domain/                              # Immutable Domain Structs (TeaField, PluckingTask)
│   │   └── DTOs/                                # Codable Models Matching FastAPI Pydantic v2
│   ├── Persistence/                             # Core Data Local Storage
│   │   ├── PersistenceController.swift          # NSPersistentContainer & Background Contexts
│   │   ├── Models/                              # TeaFieldEntity, NDVILogEntity, HarvestLogEntity
│   │   └── Repositories/                        # FieldRepository, HarvestRepository, NDVIRepository
│   ├── Services/                                # Protocol-Oriented Abstracted Services
│   │   ├── Protocols/                           # APIServiceProtocol, VisionLeafClassifierProtocol...
│   │   └── Implementations/                     # CloudAPIService, VisionLeafClassifier, LocationService...
│   ├── ViewModels/                              # @MainActor Observable State ViewModels
│   └── Views/                                   # Declarative SwiftUI Views (iPhone & iPad)
│       ├── Auth/                                # LoginView, ForcePasswordChangeView
│       ├── Manager/                             # iPad NavigationSplitView, Charts & Plucker Rosters
│       ├── Onboarding/                          # 3-Slide Carousel & Multi-Tenant Estate Wizard
│       └── Supervisor/                          # Tasks, Weighing Form, Leaf Scanner, MapKit
├── TeaYieldAIWidget/                            # WidgetKit Home Screen Extension
│   ├── Info.plist                               # Widget Extension Configuration
│   └── TeaYieldAIWidget.swift                   # TimelineProvider, Small & Medium Widget Views
├── TeaYieldAITests/                             # Modern Apple Swift Testing Suites
│   ├── Mocks/                                   # Isolated Protocol Test Doubles
│   └── Tests/                                   # 17+ Test Suites (@Test, #expect)
├── TeaYieldAIUITests/                           # UI Automation Test Harness
├── docs/                                        # Master Engineering Documentation Suite
│   ├── project_documents/
│   │   ├── COBSCCOMP251P-082_Final_Report.md    # 4-Page Final Coursework Report Document
│   │   ├── final_report_structure.md            # Report Master Blueprint & Score Maximizer
│   │   ├── screen_recording_script.md           # 3-5 Min Video Demonstration Narration Script
│   │   ├── DESIGN.md                            # Apple HIG Tokens, Typography & Data Dictionary
│   │   └── teayield_ai_proposal_submission.md   # Approved Component 1 Proposal Document
│   ├── teayield_ai_specs/                       # Technical Specifications 01 through 11
│   ├── implementation_guides/                   # Master Roadmap (WORKFLOW.md)
│   └── cw-docs/                                 # Official NIBM/Coventry Assignment Briefs
├── scripts/                                     # Linux Core ML Training & Dataset Pipelines
└── README.md                                    # Master Project Documentation
```

---

## Academic Integrity & LLM Policy Compliance

In strict compliance with the **NIBM School of Computing Academic Integrity Policy on LLM Usage**:
- 100% of executable Swift/SwiftUI application logic, ViewModels, Core Data repositories, and on-device Core ML pipelines are student-authored.
- Large Language Models are restricted exclusively to permitted non-code tasks (ideation, documentation outlines, and text proofreading).
- All permitted non-code LLM interactions are formally documented in Section 4 of the Final Report ([COBSCCOMP251P-082_Final_Report.md](docs/project_documents/COBSCCOMP251P-082_Final_Report.md)).

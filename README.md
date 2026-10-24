# TeaYield AI iOS — Precision Tea Yield Prediction & Plucking Schedule Optimization Client

[![Academic Level](https://img.shields.io/badge/ACADEMIC%20LEVEL-LEVEL%206%20(COVENTRY%20UK)-0078D4?style=for-the-badge)](https://www.coventry.ac.uk/)
[![Module](https://img.shields.io/badge/MODULE-IOS%20APPLICATION%20DEVELOPMENT-7B1FA2?style=for-the-badge)](https://www.nibm.lk/)
[![Target Grade](https://img.shields.io/badge/TARGET%20GRADE-A%2B%20DISTINCTION%20(100%25)-2EA44F?style=for-the-badge)](docs/teayield_ai_specs/07_Viva_Preparation_Guide.md)
[![Architecture](https://img.shields.io/badge/ARCHITECTURE-MVVM%20%2B%20POP%20%2B%20DI-FF6F00?style=for-the-badge)](docs/teayield_ai_specs/02_Technical_Architecture.md)
[![AI Edge Core](https://img.shields.io/badge/EDGE%20AI-COREML%20%2B%20VISION%2060FPS-1976D2?style=for-the-badge)](docs/teayield_ai_specs/03_Advanced_SDK_Spec.md)

[![Geospatial](https://img.shields.io/badge/GEOSPATIAL-MAPKIT%20%2B%20GEOFENCING-E65100?style=for-the-badge)](docs/teayield_ai_specs/03_Advanced_SDK_Spec.md)
[![Database](https://img.shields.io/badge/OFFLINE%20CACHE-COREDATA%20%2F%20SWIFTDATA-3ECF8E?style=for-the-badge)](docs/teayield_ai_specs/02_Technical_Architecture.md)
[![UI Framework](https://img.shields.io/badge/UI%20FRAMEWORK-SWIFTUI%20%2B%20CHARTS-05998B?style=for-the-badge)](docs/teayield_ai_specs/05_MultiDevice_Adaptation.md)
[![License](https://img.shields.io/badge/LICENSE-MIT-F1C40F?style=for-the-badge)](LICENSE)
[![Specification Status](https://img.shields.io/badge/SPECIFICATION%20STATUS-100%25%20AUDITED%20%26%20COMPLETE-brightgreen?style=for-the-badge)](docs/teayield_ai_specs/)

> **Target Domain:** Regional Plantation Companies (RPCs) & Sri Lankan Tea Industry  
> **Module:** iOS Application Development (Level 6, Batch BSCCOMP25.1P)  
> **Awarding Body:** Coventry University (UK) delivered at National Institute of Business Management (NIBM)  
> **Batch:** 25.1P  
> **Student:** A G K M B M BANDARA (COBSCOMP251P-082 | Coventry ID: 16604375)  
> **Target Standard:** First-Class Honours / A+ Distinction (100% Marks)  
> **Architectural Topology:** Dual-Repository Ecosystem (`teayield-ai-core` + `teayield-ai-ios`)  
> **Primary Technology Stack:** Swift 5.9+ | SwiftUI Declarative UI | SwiftData / Core Data | MapKit & CoreLocation | On-Device CoreML Vision  
> **Specification Status:** 100% Audited, Approved & Complete (Specifications 01 through 09 + Git Branching Strategy)  

---

## Executive Summary & Research Business Case

Sri Lankan commercial tea plantations (such as Pedro Estate in Nuwara Eliya) represent a cornerstone of the national agricultural economy, yet operational harvest planning across expansive, high-altitude mountain plantations remains governed by manual heuristics and visual inspection.

This operational reliance introduces three chronic systemic vulnerabilities:
1. **Labor Misallocation:** Plucking gangs are disproportionately deployed to low-yield fields, elevating unit production costs while high-yield plots experience vegetative over-maturation.
2. **Factory Withering Bottlenecks:** Uncoordinated harvest flushes exceed daily factory withering trough intake quotas, causing leaf spoilage and commercial downgrade.
3. **Quality Dilution at Weighing Checkpoints:** Piece-rate plucker compensation incentivizes the plucking of coarse foliage and mature stalks, diluting Ceylon tea auction value.

> The acquired multimodal intelligence feeds downstream automated workforce plucking rosters and on-device field-level quality inspection dashboards, establishing a zero-ground-hardware precision agriculture platform.

TeaYield AI iOS eliminates these bottlenecks by coupling cloud intelligence from `teayield-ai-core` (Sentinel-2 NDVI remote sensing, Open-Meteo meteorological reanalysis, stacked LSTM yield prediction, and DEAP Genetic Algorithm workforce scheduling) with an offline-resilient native Apple client running on-device edge AI.

---

## The Fundamental Architectural Pattern: Dual-Track API-First Model

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
| • Open-Meteo Climate Preprocessing      |       REST API        | • SwiftData / Core Data Offline Cache   |
| • Stacked Multivariate LSTM Predictor   | <───────────────────> | • Apple MapKit Interactive Polygons     |
| • DEAP Genetic Algorithm Scheduler      |   (JSON / Bearer)     | • CoreML On-Device Leaf Maturity Vision |
| • FastAPI Asynchronous Microservice    |                       | • Field Weighing Sync Forms & Checkins  |
| • Supabase PostgreSQL 15 + PostGIS      |                       | • iPadOS SplitView Operational Dashboard|
+─────────────────────────────────────────+                       +─────────────────────────────────────────+
```

### Architectural Separation of Concerns
1. **Cloud Intelligence Layer (`teayield-ai-core`):** Ingests satellite telemetry, computes 15-day rolling median canopy health (NDVI), forecasts green leaf yields via a 4-week temporal stacked LSTM, and executes multi-objective evolutionary plucking scheduling. Deployed with deterministic contract stubs under Phase 3, unblocking mobile development early in the project lifecycle.
2. **Edge Execution Layer (`teayield-ai-ios`):** Connects to FastAPI endpoints, caches weekly schedules and daily tasks offline in Core Data / SwiftData, captures GPS-tagged weighing check-ins, and executes on-device leaf quality classification at 60 FPS via the Apple Silicon Neural Engine without cellular connectivity.

---

## Coursework Assessment Architecture (100% Weightage)

This repository fulfills all six assessment components of the NIBM iOS Application Development module (BSCCOMP25.1P):

```
+-----------------------------------------------------------------------------------+
| Component 1: Prototype & MVP Approval (10%)                 [MANDATORY]           |
| Component 2: MVP Implementation, External API & Viva (20%)  [MANDATORY]           |
| Component 3: Advanced iOS SDK - On-Device (20%)             [MANDATORY]           |
| Component 4: Unit Tests, Accessibility & Docs (15%)         [ELECTIVE / MAX MARKS]|
| Component 5: Above & Beyond - iPad & Architecture (25%)    [ELECTIVE / MAX MARKS]|
| Component 6: In-Class Tutorial 4 - PlayHubApp (10%)         [ELECTIVE / MAX MARKS]|
+-----------------------------------------------------------------------------------+
```

### Component 1 — Proposal & High-Fidelity UI/UX Prototype (10% - Mandatory)
- **Problem Statement & USP:** Zero-IoT satellite agritech vs manual visual heuristics.
- **UI/UX Deliverable:** High-fidelity 10-screen Figma prototype strictly following Apple Human Interface Guidelines (HIG), supporting dynamic light/dark mode and dual size-class flows.
- **Figma Prototype Link:** [TeaYield AI — High-Fidelity iOS & iPadOS Prototype](https://www.figma.com/design/wy9cRSQbIl3aDBLoRePju0/Untitled?t=lav3FgbNLfZivYum-0)

### Component 2 — MVP Implementation, External API & Live Viva (20% - Mandatory)
- **Platform Features Chosen:**
  1. **Core Data / SwiftData:** Local relational persistence managing field boundaries, NDVI logs, and plucking sessions offline.
  2. **Biometric Security:** Face ID / Touch ID authentication via `LocalAuthentication` securing executive rosters and yield data.
- **External Integration (LO3):** Asynchronous REST API integration with `teayield-ai-core` (Python FastAPI + Supabase PostGIS) for live field boundaries, predictions, and schedules.
- **Live Viva Readiness:** Complete code ownership defense notes and architectural justification.

### Component 3 — Advanced iOS SDK (100% On-Device) (20% - Mandatory)
- **Feature 1 (On-Device Edge AI):** `VNCoreMLModel` + Vision framework running at 60fps on Apple Silicon Neural Engine to scan tea shoots in real time for fine vs coarse leaf ratio ("Two Leaves and a Bud"). Zero remote AI APIs.
- **Feature 2 (Geospatial & Geofencing):** MapKit spatial vector field polygon overlays (`MKPolygon`) and low-power background geofencing (`CLCircularRegion`) dispatching arrival notifications when entering scheduled fields.

### Component 4 — Swift Testing, Accessibility & Documentation (15%)
- **Modern Swift Testing:** Uses Apple's modern testing framework (`import Testing`, `@Test`, `#expect`), avoiding legacy XCTest.
- **100% VoiceOver Accessibility:** Descriptive `.accessibilityLabel` and `.accessibilityHint` on all UI controls and camera overlays. Full Dynamic Type font scaling.
- **4-Page Structured Report PDF:** Executive summary, architecture diagrams, technical challenges, explicit Learning Outcomes reflection (LO1–LO4), and non-code LLM usage log.

### Component 5 — Above & Beyond (25% - Maximum Weightage)
- **Multi-Device Adaptation (LO1):** iPhone compact single-column supervisor flow vs iPad regular desktop-class 3-column `NavigationSplitView` executive suite.
- **Apple Charts Framework:** Native `BarMark` and `LineMark` visualizations comparing 7-day predicted yields against historical actuals and factory withering capacity gauges.
- **Architecture & Polish:** Protocol-Oriented Programming (POP), Dependency Injection container (`AppContainer`), matched geometry transitions, and micro-haptics (`UIImpactFeedbackGenerator`).

### Component 6 — In-Class Tutorial 4 "PlayHubApp" (10%)
- Integration and refactor of Tutorials 1-3 game modes (*Tap Frenzy*, *Light It Up*, *Quiz Rush*) into a polished MVVM application shell featuring Swift Charts, MapKit session pins, local notifications, and `UserDefaults` persistence.

---

## Swift & SwiftUI Architectural Blueprint

The application enforces strict separation of concerns through MVVM, Protocol-Oriented Programming, and Dependency Injection:

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

## Production Domain Seed Reference (Nuwara Eliya Pedro Estate)

All models, offline mock fixtures, and simulator workflows are synchronized with the backend database:

- **Target Estate:** Nuwara Eliya High-Grown Estate (Pedro Estate, Upper Division - ID: `3b241101-5231-4822-a982-f87c126d4001`)
- **Field Polygons:**
  - `Upper Division Block A` (ID: `7c9e6679-7425-40de-944b-e07fc1f90ae7` | Area: 12.5 Ac | Peak NDVI: 0.820 | Status: READY)
  - `Middle Valley Block B` (ID: `8d1f7780-8536-41ef-055c-f18fd2a01bf8` | Area: 15.0 Ac | Mid NDVI: 0.740 | Status: GROWING)
  - `Lower Ravine Block C` (ID: `9e2a8891-9647-42f0-166d-a29fe3b12ca9` | Area: 9.8 Ac | Rest NDVI: 0.580 | Status: RESTING)
  - `High Peak Ridge Block D` (ID: `a34b9902-0758-4301-277e-b30af4c23db0` | Area: 18.2 Ac | NDVI: 0.690 | Status: GROWING)
- **Workforce Sample Pluckers:**
  - `EMP-4012`: K. Meenakshi (Target: 27.5 kg/day)
  - `EMP-4013`: S. Kamalasani (Target: 24.8 kg/day)
  - `EMP-4014`: R. Thavamani (Target: 26.2 kg/day)
  - `EMP-4016`: P. Vijaya (Target: 28.5 kg/day)

---

## Repository Architecture & Codebase Structure

The codebase adheres to clean MVVM and Protocol-Oriented modular separation:

```
teayield-ai-ios/
├── TeaYieldAI/
│   ├── App/                                     # App Lifecycle & Dependency Injection Container
│   ├── Core/
│   │   ├── Network/                             # Endpoint Builder, Error Enums & Network Monitor
│   │   ├── Security/                            # Secure Enclave Keychain Helper
│   │   └── Utilities/                           # AppConfiguration & Dynamic Environment Helpers
│   ├── Preview Content/                         # SwiftUI Preview Assets & Pedro Estate Mock Fixtures
│   ├── Models/
│   │   ├── Domain/                              # Immutable Pure Domain Structs (TeaField, PluckingTask, etc.)
│   │   └── DTOs/                                # Swift Codables matching FastAPI Pydantic v2
│   ├── Services/
│   │   ├── Protocols/                           # Abstract Service Interfaces for Unit Testing
│   │   └── Implementations/                     # URLSession REST Client & Face ID Auth
│   ├── Persistence/
│   │   ├── Repositories/                        # Thread-Safe Core Data SQLite Repositories
│   │   └── Models/                              # Core Data NSManagedObject Entities
│   ├── ViewModels/                              # @MainActor Observable State ViewModels
│   └── Views/                                   # Declarative SwiftUI Views (iPhone & iPad)
├── docs/
│   ├── project_documents/
│   │   ├── DESIGN.md                            # Product HIG Tokens, Typography & Data Dictionary
│   │   ├── teayield_ai_figma_prototype_plan.md  # 10-Screen Figma Prototype Specifications
│   │   └── teayield_ai_proposal_submission.md   # Final Component 1 Proposal Document & Figma Link
│   ├── teayield_ai_specs/
│   │   ├── 01_App_Proposal_Figma.md             # Component 1 Specification
│   │   ├── 02_Technical_Architecture.md         # Component 2 MVVM, Core Data & API Schema Spec
│   │   ├── 03_Advanced_SDK_Spec.md              # Component 3 Core ML Vision & MapKit Spec
│   │   ├── 04_Testing_Accessibility_Plan.md     # Component 4 Swift Testing & VoiceOver Plan
│   │   ├── 05_MultiDevice_Adaptation.md         # Component 5 iPad SplitView & Polish Spec
│   │   ├── 06_Final_Report_Template.md          # Component 4 4-Page PDF Final Report Template
│   │   ├── 07_Viva_Preparation_Guide.md         # Component 2 Viva Technical Defense Guide
│   │   ├── 08_Component6_Tutorial4_Spec.md      # Component 6 Tutorial 4 PlayHubApp Spec
│   │   ├── 09_Backend_REST_API_Contract.md      # FastAPI REST Route Contracts & Swift Codable
│   │   └── GIT_BRANCHING_STRATEGY.md            # Git Flow, Branch Standards & Release Sync
│   ├── implementation_guides/
│   │   └── WORKFLOW.md                          # Master Timeline & Definition of Done
│   └── cw-docs/
│       ├── iOS_CW_Assessment_2026.pdf           # NIBM Official Coursework Assessment Document
│       ├── Research_Project_Seeding.docx        # Academic Research Seeding Guidelines
│       └── tea_yield_prediction_proposal.md     # Core Scientific Research Proposal
└── README.md                                    # Master Project Documentation
```

---

## Academic Integrity & LLM Policy Compliance

In strict compliance with the **NIBM School of Computing Academic Integrity Policy on LLM Usage**:
- 100% of executable Swift/SwiftUI application logic, ViewModels, and services are student-authored.
- Large Language Models are restricted exclusively to permitted non-code tasks (ideation, documentation outlines, and text proofreading).
- All permitted non-code LLM interactions are formally documented in Section 4 of the Final Report.

# Component 4 Deliverable: Final Report Structure & Learning Outcomes Reflection
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Format:** 4-Page Structured PDF Document  
**Weightage:** Part of Component 4 (15%)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Module:** iOS Application Development — BSc (Hons) Computing (BSCCOMP25.1P)  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  

---

## Page 1: Executive Overview, Problem Domain & UI Showcases

### 1.1 Executive Overview & Problem Domain
- **Problem Statement:** Traditional Sri Lankan tea estates rely on visual heuristics for plucking schedules, causing labor mismatch and factory processing bottlenecks.
- **Solution & USP:** TeaYield AI combines satellite remote sensing (Sentinel-2 NDVI), Open-Meteo weather data, Python LSTM yield forecasting, and Genetic Algorithm roster scheduling without expensive IoT hardware.
- **Target Profiles:** Estate Managers (iPad Executive Suite) and Field Superintendents (iPhone Mobile Workflow).

### 1.2 High-Fidelity Screenshots Showcase
- **iPhone Screenshots:** Today's Tasks List, On-Device Core ML Shoot Quality Scanner Viewfinder, MapKit Geofence Alert Notification.
- **iPad Screenshots:** Multi-column `NavigationSplitView` Estate Manager Suite, Interactive Heatmap Canvas, Swift Charts Yield Analytics, Genetic Algorithm Roster Export Dialog.

---

## Page 2: Technical Architecture & System Implementation

### 2.1 MVVM + POP Architecture Diagram
- Visual diagram showing declarative SwiftUI Views -> `@Observable` ViewModels -> Protocol-based Services -> Core Data & Supabase Repositories.

### 2.2 Core Data Relational Schema & Offline Persistence
- Entity Relationship (ER) Diagram: `TeaFieldEntity`, `NDVILogEntity`, `PluckingSessionEntity`, and `UserProfileEntity`.
- Offline caching lifecycle explanation: Local writes in remote fields with background sync via `NWPathMonitor`.

### 2.3 Cloud Backend Integration & Security
- REST API synchronization specs between iOS app, Supabase PostGIS DB, and Python FastAPI backend (`POST /api/v1/yield/predict`, `POST /api/v1/roster/optimize`, `POST /api/v1/harvest/sync`).
- Biometric security integration using `LocalAuthentication` Face ID for financial roster access control.

---

## Page 3: Advanced iOS SDKs (On-Device) & Technical Challenges

### 3.1 On-Device Computer Vision & Core ML Shoot Scanner
- Real-time 60fps camera buffer processing using Apple Silicon Neural Engine (`CoreML` + `Vision`).
- Zero cloud API dependency justification and fine-to-coarse leaf ratio classification logic (*"Two Leaves and a Bud"*).

### 3.2 MapKit & Active Geofencing System
- Dynamic spatial polygon rendering (`MKPolygon`) and `CLCircularRegion` background geofencing alerts upon entering harvest-ready fields.

### 3.3 Technical Challenges & Engineering Solutions
1. *Challenge:* High memory overhead during 60fps camera frame processing.  
   *Solution:* Optimized pixel buffer reuse using `CVPixelBuffer` pool management.
2. *Challenge:* Offline sync conflicts in remote mountain locations.  
   *Solution:* Implemented UUID primary keys and timestamp-based last-write-wins resolution.

---

## Page 4: Learning Outcomes (LO1–LO4) Reflection & Mandatory LLM Log

### 4.1 Learning Outcomes Reflection Matrix
| Learning Outcome | Description | Specific TeaYield AI Project Evidence & Justification |
| :--- | :--- | :--- |
| **LO1 — Multi-Device Adaptation** | Critically evaluate platform components across devices | Native layout adaptation for iPhone (compact single-column mobile flow) and iPad (`NavigationSplitView` desktop-class executive suite). |
| **LO2 — Mobile Architecture** | Design & evaluate mobile software architecture | Production MVVM architecture, Protocol-Oriented Services, Dependency Injection container, and modular codebase structure. |
| **LO3 — External APIs & Services** | Develop apps interacting with external APIs | Integration of Python FastAPI REST backend, Sentinel-2 Satellite API, Open-Meteo Weather API, and Supabase cloud DB. |
| **LO4 — Device Sensors & Hardware** | Develop apps communicating with phone sensors | Apple Silicon Neural Engine (`CoreML`/`Vision`), `CoreLocation` background geofencing, and `LocalAuthentication` Face ID sensors. |

### 4.2 Mandatory LLM Usage Log & Academic Integrity Declaration
- **Permitted LLM Scope Log:**
  - *Task:* Brainstorming USP & structuring documentation outlines.
  - *Prompts Used:* "Structure a 4-page report template for an iOS agritech application..."
- **Academic Integrity Declaration:**
  - Formal student declaration confirming 100% of executable Swift/SwiftUI source code was student-authored without LLM code generation tools.

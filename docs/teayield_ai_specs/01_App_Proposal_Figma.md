# Component 1 Specification: App Proposal & High-Fidelity UI/UX Prototype
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 10% (Mandatory Component)  
**Author:** Bhanuka Bandara (Student ID: 082)  
**Module:** iOS Application Development — BSC (Hons) Computing (BSCCOMP25.1P)  
**Affiliation:** National Institute of Business Management (NIBM)  

---

## 1. Executive Summary & Problem Domain

### 1.1 Executive Description (1–2 Paragraphs)
In traditional Sri Lankan tea estates, tea leaf harvesting (plucking) schedules and labor allocations are managed manually using historical heuristics and visual intuition. Because tea leaf growth is highly sensitive to micro-climatic fluctuations (daily rainfall, temperature, humidity), weekly crop yields vary dynamically. Manual scheduling frequently results in severe **labor mismatch** (over-allocating pluckers to low-yield fields or under-allocating pluckers to peak-yielding fields) and **factory processing bottlenecks** (leaf surges exceeding factory withering capacity, leading to leaf spoilage).

**TeaYield AI** is a novel, precision agriculture platform designed specifically for tea estate management. It eliminates the need for expensive on-site Internet of Things (IoT) sensors by leveraging free remote sensing satellite imagery (**Sentinel-2 NDVI**) and meteorological climate APIs (**Open-Meteo**). By coupling a temporal **LSTM (Long Short-Term Memory) Deep Learning Neural Network** for weekly crop yield forecasting with a **Genetic Algorithm (GA)** scheduler for labor allocation, TeaYield AI automatically generates optimized, conflict-free plucking rosters. The platform delivers a dual-device Native iOS experience: an **iPhone Mobile Workflow** for Field Superintendents (camera shoot quality scanning and geofenced field alerts) and an **iPad Desktop Executive Suite** for Estate Managers (`NavigationSplitView` analytics and interactive roster generation).

### 1.2 Target Audience & User Profiles
1. **Estate Managers / Regional Agronomists (Executive User Profile):**
   - *Device:* iPad / iPad Pro (Regular Size Class).
   - *Needs:* Macro-level estate visualization, 7-day crop yield forecasts, dynamic Genetic Algorithm roster generation, factory capacity monitoring, and PDF/CSV roster exports.
2. **Field Superintendents / Supervisors (Operational User Profile):**
   - *Device:* iPhone / iPhone Pro (Compact Size Class).
   - *Needs:* On-device camera shoot maturity scanning (bud-to-leaf ratio), active GPS geofencing notifications upon entering scheduled field polygons, daily plucking checklists, and offline telemetry caching.

### 1.3 Unique Selling Point (USP)
* **Zero-IoT Hardware Cost:** Operates 100% without physical ground sensors or drones by utilizing Sentinel-2 multi-spectral satellite imagery and Open-Meteo weather data.
* **On-Device 0-Latency AI Vision:** Field leaf quality is evaluated 100% on-device using Apple Silicon Neural Engine (`CoreML` + `Vision`), ensuring zero cloud dependency in remote, signal-free mountain fields.
* **Integrated Prediction-to-Action Pipeline:** Bridges the gap between raw prediction numbers and operational action by converting predictions directly into actionable worker rosters via Genetic Algorithm optimization.

---

## 2. Feature Breakdown & System Scope

### 2.1 Core Features (MVP Baseline)
1. **Estate Polygon Boundary Registration:** Interactive mapping and logging of field boundary coordinates as spatial GeoJSON polygons using MapKit and Supabase PostGIS.
2. **Environmental & Satellite Data Synchronization:** Automated API calls to Sentinel Hub (Sentinel-2 Band 4 Red & Band 8 NIR for NDVI calculation) and Open-Meteo climate records.
3. **Core Data Local Persistence:** Complete offline persistence of field polygons, weather logs, and plucking session records across app launches.
4. **Biometric Estate Security (Face ID / Touch ID):** Encrypted login and access control for corporate financial labor rosters and yield analytics using `LocalAuthentication`.
5. **Python Cloud AI Backend Integration:** REST API connectivity to Python FastAPI backend running the PyTorch LSTM yield forecasting model and DEAP Genetic Algorithm optimizer.

### 2.2 Advanced Features
1. **On-Device Core ML Shoot Quality Scanner:** Real-time 60fps camera buffer segmentation classifying fine leaf vs coarse leaf ratios (*"Two Leaves and a Bud"*).
2. **Active Spatial Geofencing System:** Background GPS region monitoring (`CLCircularRegion`) dispatching local alerts when field superintendents enter fields scheduled for harvesting today.
3. **Multi-Channel Notification Engine:** Weather hazard warnings, factory capacity overload alerts, and field rest cycle expiry notifications.

---

## 3. High-Fidelity UI/UX Prototype Specification (Figma)

### 3.1 Design System & Guidelines Compliance
- **Apple Human Interface Guidelines (HIG) Compliance:** Uses native iOS navigation patterns, fluid sheet presentations, SF Symbols 5 iconography, and standard touch target sizes (minimum 44x44 pt).
- **Color Palette (Dark & Light Mode Adaptive):**
  - *Primary Accent:* Emerald Green (`#059669` / `Color.emerald`) — Represents healthy tea shoots (High NDVI).
  - *Secondary Accent:* Amber Gold (`#D97706`) — Represents fields approaching harvest readiness.
  - *Warning / Hazard:* Crimson Red (`#DC2626`) — Represents field rest cycles / heavy rain warnings.
  - *Background:* Dynamic Semantic Tokens (`Color(uiColor: .systemGroupedBackground)`).
- **Typography Scale:** Native SF Pro with full Dynamic Type font scaling support (`.font(.largeTitle)`, `.font(.headline)`, `.font(.body)`).

### 3.2 Key Screen Flows & Wireframe Navigation

#### A. iPhone Field Supervisor Navigation Flow (Compact Size Class)
```
[App Launch / Face ID Prompt]
          │
          ▼
   [TabBar Shell]
   ├── Tab 1: Today's Tasks (List of assigned fields + Geofence status badge)
   ├── Tab 2: Leaf Scanner (Live Camera Viewfinder + Core ML Overlay)
   ├── Tab 3: Field Map (MapKit vector polygons + Current GPS location)
   └── Tab 4: Settings (Offline Sync status + VoiceOver toggles)
```

#### B. iPad Estate Manager Executive Flow (Regular Size Class)
```
[NavigationSplitView Shell]
 ├── Sidebar Pane: Estate Fields List (Search, Filter by NDVI status)
 ├── Content Pane: Interactive Satellite Heatmap + Field Polygon Overlays
 └── Detail Pane: 
      ├── Swift Charts (7-Day Predicted Yield vs Historical Actuals)
      ├── Genetic Algorithm Roster Optimizer Controls (Worker count, shift days)
      └── Roster Summary Table + PDF/CSV Export Action Toolbar
```

---

## 4. Technical Stack & Justification Matrix

| Technology / Framework | Category | Purpose | Technical Justification |
| :--- | :--- | :--- | :--- |
| **SwiftUI** | UI Framework | Native User Interface | Declarative syntax, seamless dynamic layout adaptation between iPhone and iPad size classes. |
| **Core Data** | Local Storage | Offline Data Caching | Native relational SQLite wrapper; ensures full app functionality in remote mountain fields without internet. |
| **LocalAuthentication** | Security | Biometric Auth | Hardware-level Face ID / Touch ID protection for sensitive corporate financial rosters via Secure Enclave. |
| **Vision + Core ML** | On-Device AI | Shoot Quality Scanner | Executes ML model 100% on-device on Apple Silicon Neural Engine with zero latency and zero cloud costs. |
| **MapKit + Core Location**| Geospatial | Mapping & Geofencing | Renders vector polygons (`MKPolygon`) and executes low-power background region monitoring (`CLCircularRegion`). |
| **Supabase + PostGIS** | Cloud Database | Spatial Data Store | Open-source PostgreSQL cloud DB with PostGIS extensions for spatial GeoJSON boundary queries and auth. |
| **Python FastAPI** | Cloud Backend | AI & Optimization Engine | High-performance Python async REST API hosting PyTorch LSTM yield model and DEAP Genetic Algorithm scheduler. |
| **Swift Testing** | Quality Assurance | Unit Test Suite | Apple's modern `import Testing` framework for concise, macro-driven ViewModel and service tests. |

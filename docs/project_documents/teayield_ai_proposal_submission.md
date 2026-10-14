# Coursework Proposal & UI/UX Prototype Specification
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Module Name:** iOS Application Development (BSCCOMP25.1P)  
**Degree Programme:** BSc (Hons) in Computing  
**Student Name:** Bhanuka Bandara  
**Student ID:** 082  
**Institution:** National Institute of Business Management (NIBM) — School of Computing  
**Submission Date:** September 2026  

---

## 1. Executive Summary & Problem Statement

### 1.1 Problem Statement
The tea industry is a major driver of Sri Lanka's agricultural economy. Efficient management of tea estates depends heavily on accurate scheduling of tea leaf harvesting (plucking). However, tea leaf shoot growth is highly sensitive to micro-climatic factors such as daily rainfall, temperature fluctuations, and soil moisture levels. Consequently, weekly crop yields vary dynamically across different field sections within an estate.

In traditional Sri Lankan tea estates, plucking schedules and workforce allocations are managed manually based on visual inspection and historical heuristics. Supervisors walk through fields and estimate readiness based on personal intuition. This manual approach leads to two major operational failures:
1. **Workforce Allocation Mismatch:** Over-allocating pluckers to low-yielding fields inflates labor costs while yielding poor productivity. Conversely, under-allocating pluckers to peak-yielding fields causes leaves to overgrow beyond their optimal window.
2. **Factory Processing Bottlenecks:** Sudden, unpredictable spikes in harvested leaf volume frequently exceed the daily withering and processing capacity of the estate factory, causing rapid leaf degradation and economic loss.

Existing digital agriculture systems fail to solve this problem for local tea estates due to a heavy reliance on expensive, ground-based Internet of Things (IoT) sensors or drones. Deploying and maintaining thousands of IoT devices across vast, mountainous terrains is financially unfeasible for local plantations.

### 1.2 Proposed Solution: TeaYield AI
**TeaYield AI** is a precision agriculture platform designed specifically for tea estate management. It completely eliminates the need for physical on-site IoT hardware by utilizing free, multi-temporal satellite imagery from the European Space Agency's **Sentinel-2** satellite alongside climate data from the **Open-Meteo API**. 

The platform operates through a two-layer computational pipeline:
* **Layer 1 (Temporal Yield Forecasting):** A Long Short-Term Memory (LSTM) deep learning neural network predicts weekly crop yields (in kilograms) for every field by analyzing temporal shifts in the Normalized Difference Vegetation Index (NDVI) and rolling weather history.
* **Layer 2 (Plucking Schedule Optimization):** A Genetic Algorithm (GA) takes the predicted yields, field distances, labor capacities, and factory limits to automatically compute an optimized, conflict-free plucking roster.

Delivered as a native Apple application, TeaYield AI provides a tailored dual-device experience: a mobile workflow on **iPhone** for Field Superintendents and a multi-column desktop-class executive suite on **iPad** for Estate Managers.

---

## 2. Target Audience & User Profiles

TeaYield AI targets two primary operational user profiles within commercial tea plantation companies:

### 2.1 Operational Profile: Field Superintendents (iPhone Flow)
- **Primary Device:** iPhone / iPhone Pro (Compact Size Class).
- **Work Context:** Active outdoors in mountainous tea fields with intermittent or zero cellular connectivity.
- **Key Needs:** 
  - Quick visual verification of daily assigned plucking fields.
  - On-device camera scanning to verify leaf shoot maturity before plucking begins.
  - Automatic location-based alerts when stepping into designated harvest fields.
  - Simple, offline-first data entry for daily harvested weights.

### 2.2 Executive Profile: Estate Managers & Agronomists (iPad Flow)
- **Primary Device:** iPad / iPad Pro (Regular Size Class).
- **Work Context:** Based in the estate central office or regional corporate headquarters.
- **Key Needs:**
  - Macro-level visualization of the entire estate via satellite heatmaps.
  - 7-day predicted crop yield trends across all field sections.
  - Dynamic generation and customization of worker rosters.
  - Factory processing capacity tracking and official roster exports (PDF/CSV).

---

## 3. Core Functionality & Unique Selling Point (USP)

### 3.1 Unique Selling Point (USP)
* **Zero-IoT Hardware Expense:** Operates entirely without physical ground sensors, soil probes, or drones, leveraging free satellite remote sensing data (Sentinel-2) and open weather APIs.
* **On-Device 0-Latency AI Inspection:** Field leaf quality is evaluated 100% on-device using the Apple Silicon Neural Engine (`CoreML` + `Vision`), guaranteeing offline functionality in remote mountain fields.
* **Integrated Prediction-to-Action Roster Engine:** Translates raw yield predictions directly into actionable daily worker allocations using Genetic Algorithm optimization rather than stopping at static numbers.

---

## 4. Detailed Feature Breakdown

### 4.1 Core MVP Features (Component 2 Scope)
1. **Spatial Boundary Registration:** Field coordinates are mapped and saved as GeoJSON polygons stored in a Supabase PostGIS spatial database.
2. **Satellite & Climate Data Sync:** Automated data ingestion fetching Sentinel-2 spectral bands (Red Band 4 and Near-Infrared Band 8 for NDVI calculation) and Open-Meteo weather parameters.
3. **Core Data Offline Caching:** Complete local SQLite persistence managing field records, historical NDVI logs, and plucking logs offline.
4. **Biometric Security Vault:** Face ID / Touch ID authentication via `LocalAuthentication` protecting corporate financial labor costs and yield reports.
5. **Python Backend Synchronization:** REST API connectivity to a Python FastAPI service hosting the PyTorch LSTM yield predictor and DEAP Genetic Algorithm optimizer.

### 4.2 Advanced Features (Components 3 & 5 Scope)
1. **On-Device Core ML Shoot Quality Scanner:** Real-time 60fps camera buffer analysis classifying fine leaf vs coarse leaf ratios (*"Two Leaves and a Bud"*) directly on Apple Silicon hardware.
2. **Active Spatial Geofencing System:** Background GPS region monitoring (`CLCircularRegion`) dispatching local alerts when superintendents enter fields scheduled for plucking.
3. **Multi-Channel Event Alerts:** Automated local notifications for rainfall hazards, factory overload warnings, and field rest period completions.
4. **iPad Executive Suite (`NavigationSplitView`):** Multi-pane desktop layout with interactive satellite heatmaps and Swift Charts analytics (`BarMark`, `LineMark`).

---

## 5. UI/UX Prototype Specification (Figma Wireframe Plan)

> [!IMPORTANT]
> **Interactive Figma Prototype Deliverable:**  
> **Figma Link:** [TeaYield AI — High-Fidelity iOS & iPadOS Interactive Prototype](https://www.figma.com/design/wy9cRSQbIl3aDBLoRePju0/Untitled?t=lav3FgbNLfZivYum-0) *(Paste your copied Figma share link here)*

### 5.1 Design System & HIG Compliance
TeaYield AI strictly follows Apple's **Human Interface Guidelines (HIG)**:
- **Color Tokens:** Semantic, high-contrast palette. Primary Emerald Green (`#10B981` / `#059669`) for peak NDVI & primary actions, Amber Gold (`#D97706`) for mid-growth fields, Crimson Red (`#DC2626`) for field rest periods, and Deep Slate (`#0B1912` / `#0F172A`) for dark glassmorphic camera overlays.
- **Typography:** Native SF Pro Text & SF Pro Display fonts with Dynamic Type accessibility scaling.
- **Iconography:** Apple SF Symbols 5 for clear operational iconography and hardware biometric feedback.

### 5.2 Complete Screen Flow Breakdown

#### Mobile Flow (iPhone Size Class — Field Superintendent)
1. **Screen 01 (Welcome & Platform Onboarding):** Introduces Zero-IoT satellite yield prediction, Sentinel-2 spectral analysis, and core estate targets.
2. **Screen 02 (User Registration & Access Tier):** Dual role selector (Field Superintendent vs. Estate Manager), corporate domain verification (`bhanuka@pedroestates.lk`), and assigned block authorization.
3. **Screen 03 (Biometric Face ID Authentication):** Secure biometric login using `LocalAuthentication` with TrueDepth HUD feedback and passcode fallback.
4. **Screen 04 (Tasks Home & Active Geofence Alert):** Live GPS geofence arrival detection banner ("Field 01 — 25 Pluckers Assigned"), shift target gauges, and harvest task list.
5. **Screen 05 (Core ML Shoot Quality Scanner HUD):** Real-time 60fps camera viewfinder running Vision framework (`VisionTransformer-v3.2`) with bounding box HUD ("88% Fine Leaf — Two Leaves & Bud") and Core Data log trigger.
6. **Screen 06 (Spatial MapKit GIS Polygon Explorer):** Interactive vector map overlaying field polygons (`MKPolygon`), elevation contours, and active geofences (`CLCircularRegion`).

#### Executive Suite (iPad Landscape Size Class — Estate Manager)
7. **Screen 07 (iPadOS Executive 3-Column NavigationSplitView Dashboard):** Desktop-class 3-column layout featuring:
   - **Column 1 (Sidebar):** Primary navigation (Overview, Spatial Intelligence, Harvest Telemetry, Workforce Roster, Factory Intake).
   - **Column 2 (Content Pane):** Field section selector cards with real-time NDVI health tags.
   - **Column 3 (Detail Pane):** Swift Charts 7-Day Yield Forecast vs Actual telemetry, Pedro Factory Intake capacity meter, and Genetic Algorithm Plucker Optimization Engine.

---

## 6. Technical Stack & Justification Matrix

| Technology / Framework | Category | Technical Justification |
| :--- | :--- | :--- |
| **SwiftUI** | UI Framework | Declarative syntax enabling dynamic multi-device adaptation between iPhone and iPad size classes. |
| **Core Data** | Local Storage | Native SQLite ORM providing offline data access and background synchronization in mountain fields. |
| **LocalAuthentication** | Security | Hardware-level Face ID / Touch ID authentication securing manager financial rosters. |
| **Vision + Core ML** | On-Device AI | Runs computer vision models on Apple Silicon Neural Engine with zero latency and zero cloud costs. |
| **MapKit + Core Location**| Geospatial | Renders vector polygons (`MKPolygon`) and monitors background geofences (`CLCircularRegion`). |
| **Supabase + PostGIS** | Cloud Database | PostgreSQL cloud database supporting spatial GeoJSON boundary queries and real-time auth. |
| **Python FastAPI** | Cloud Backend | Async Python REST API hosting PyTorch LSTM yield forecasting models and Genetic Algorithm schedulers. |
| **Swift Testing** | Quality Assurance | Apple's modern `import Testing` framework for concise, macro-driven unit testing. |

# Figma UI/UX Prototype Specification & Design System Architecture
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Module Name:** iOS Application Development (BSCCOMP25.1P)  
**Degree Programme:** BSc (Hons) in Computing  
**Student Name:** Bhanuka Bandara  
**Student ID:** 082 | **Coventry ID:** 16604375  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  
**Document Purpose:** Master Design System Specification & Prompt Engineering Reference for AI Design Generators (Google Stitch / Figma AI)  

---

## 1. Design Philosophy & Modern iOS HIG System

TeaYield AI strictly adheres to **Apple's Human Interface Guidelines (HIG)**, incorporating modern iOS UI/UX design trends—including **Glassmorphism / SwiftUI Materials (`.ultraThinMaterial`)**, dynamic light/dark mode tokens, micro-interactions, haptic feedback integration (`UIImpactFeedbackGenerator`), and high-contrast outdoor legibility.

The platform provides a **unified responsive design system**. A single codebase dynamically adapts between **iPhone (Compact Size Class)** for Field Superintendents outdoors and **iPad (Regular Size Class)** for Estate Managers in executive office environments.

### 1.1 Live Activities & Dynamic Island Integration (`ActivityKit`)
To deliver a modern iOS experience, TeaYield AI utilizes the **Dynamic Island** and **Live Activities**:
- **Compact View:** Displays real-time camera shoot quality scanner status ("Leaf Scan: 88% Fine Leaf — Two Leaves & A Bud").
- **Expanded View:** Displays active Geofence field monitoring and daily harvested weight progress against estate factory quotas.

---

## 2. Realistic Production Dummy Data Dictionary

To ensure 100% production realism (zero generic placeholder text), all generated screens use the following domain-specific data synchronized with the backend core (`teayield-ai-core`):

- **Estate Name & Region:** Nuwara Eliya High-Grown Estate (Pedro Estate, Upper Division - ID: `3b241101-5231-4822-a982-f87c126d4001`)
- **Field Identifiers (Spatial Polygons):**
  - Upper Division Block A (`7c9e6679-7425-40de-944b-e07fc1f90ae7`): 12.50 Acres, Peak NDVI: 0.820, Status: READY
  - Middle Valley Block B (`8d1f7780-8536-41ef-055c-f18fd2a01bf8`): 15.00 Acres, Mid NDVI: 0.740, Status: GROWING
  - Lower Ravine Block C (`9e2a8891-9647-42f0-166d-a29fe3b12ca9`): 9.80 Acres, Rest NDVI: 0.580, Status: RESTING
  - High Peak Ridge Block D (`a34b9902-0758-4301-277e-b30af4c23db0`): 18.20 Acres, NDVI: 0.690, Status: GROWING
- **User Profile 1 (Operational):** Kusal Bandara — Field Superintendent (Employee ID: SUP-402)
- **User Profile 2 (Executive):** Bhanuka Bandara — Senior Estate Manager (Employee ID: MGR-082)
- **Plucker Workforce:**
  - EMP-4012: K. Meenakshi (Daily Target: 27.5 kg)
  - EMP-4013: S. Kamalasani (Daily Target: 24.8 kg)
  - EMP-4014: R. Thavamani (Daily Target: 26.2 kg)
  - EMP-4016: P. Vijaya (Daily Target: 28.5 kg)
- **Agricultural & Processing Metrics:**
  - Peak NDVI Index: `0.82 (High Chlorophyll - Peak Harvest Window)`
  - Rest NDVI Index: `0.58 (Low Chlorophyll - Field Rest Cycle)`
  - Daily Harvest Weight Target: `850 kg (Block A Daily Quota)`
  - Fine Leaf Quality Target: `88% Fine Leaf (Two Leaves and a Bud Standard)`
  - Weather Telemetry: `19.8°C Sunny, Humidity 78%, Rainfall 0.2mm`
  - Daily Factory Withering Trough Capacity: `3,000 kg (Safe Intake Range)`

---

## 3. Design System Tokens & Foundations

### 3.1 Color Palette Tokens (Dark & Light Mode Adaptive)

| Token Name | Light Hex | Dark Hex | Purpose & Context |
| :--- | :--- | :--- | :--- |
| **`Primary Emerald`** | `#059669` | `#10B981` | Peak harvest readiness (High NDVI 0.75-0.85), primary action buttons. |
| **`Secondary Amber`** | `#D97706` | `#F59E0B` | Mid-growth phase (Harvest ready in 3-5 days), caution alerts. |
| **`Rest Crimson`** | `#DC2626` | `#EF4444` | Field rest period (Do not pluck), severe rainfall hazard warnings. |
| **`Background Primary`**| `#F9FAFB` | `#111827` | Primary view canvas background. |
| **`Surface Glass`** | `rgba(255,255,255,0.75)` | `rgba(31,41,55,0.75)` | Glassmorphic floating cards and navigation overlays (`.ultraThinMaterial`). |
| **`Text Primary`** | `#111827` | `#F9FAFB` | Primary headlines and high-emphasis labels. |
| **`Text Secondary`** | `#4B5563` | `#9CA3AF` | Supporting metadata, subtitles, and timestamps. |

### 3.2 Typography Scale (SF Pro & Dynamic Type)
- **Large Title:** SF Pro Display Bold, 34pt / `.largeTitle` (Primary screen headers).
- **Title 1 / Headline:** SF Pro Text Semibold, 22pt / `.headline` (Card headlines, section titles).
- **Body:** SF Pro Text Regular, 17pt / `.body` (Main content, table cell labels).
- **Caption / Subheadline:** SF Pro Text Medium, 13pt / `.caption` (Status badges, timestamps, tags).

### 3.3 Radius, Elevation & Touch Targets
- **Padding Scale:** 4pt, 8pt, 12pt, 16pt (Standard Card Padding), 24pt, 32pt.
- **Corner Radius:** 8pt (Badges/Buttons), 12pt (Standard Cards), 16pt (Modal Sheets), 20pt (iPad Canvas Containers).
- **Touch Target:** Minimum 44x44 pt interactive hit area across all controls.

---

## 4. Master Component Library Architecture (Figma Variants & States)

All Figma screens are constructed using modular, reusable Master Components with explicit variant states (Default, Hover, Pressed, Focused, Disabled, Loading).

```
Figma Master Component Library
├── Buttons Component Set/
│   ├── Primary Emerald Button (Default, Pressed, Loading, Disabled)
│   ├── Secondary Glass Button (.ultraThinMaterial background)
│   └── Circular Icon Button (44x44pt, SF Symbols 5 icon)
├── Form & Input Controls/
│   ├── Floating Label Text Field (Default, Focused, Error)
│   ├── Secure Password Field (with Show/Hide Toggle)
│   ├── Role Picker Segmented Control (Field Superintendent vs Estate Manager)
│   ├── Plucker Capacity Slider (Interactive thumb state)
│   └── Dynamic Shift Picker (5-Day / 6-Day / 7-Day Cycle)
├── Cards & Containers/
│   ├── Field Status Card (Compact Stack & Expanded Detail)
│   ├── Active Geofence Arrival Alert Banner (Floating Toast)
│   ├── Today's Plucking Task Item Card (Checkmark state)
│   └── Analytics Container Glass Card
├── Badges, Pills & Toasts/
│   ├── Readiness Status Badge (Peak Green / Mid Yellow / Rest Red)
│   ├── Face ID Biometric Lock Pill
│   └── Offline Storage Cache Toast Notification
└── Navigation Components/
    ├── iPhone Bottom TabBar (4 Tabs: Tasks, Scanner, Map, Settings)
    ├── iPad NavigationSplitView Sidebar (3 Columns)
    └── Top Navigation Bar with Action Toolbar & Profile Avatar
```

---

## 5. Complete 10-Screen Inventory & Visual Specifications

The design maps an end-to-end user journey across **10 high-fidelity screens**, detailing layout hierarchy, component variants, micro-interactions, realistic data, and accessibility metadata.

### Screen 01: Welcome & Interactive Onboarding View
- **Header:** Brand Splash Icon (Emerald Leaf + AI Sparkle) & Skip Button.
- **Content:** Full-width feature carousel ("Zero-IoT Satellite Yield Prediction & Plucking Optimization"), 3 page indicator dots.
- **Actions:** Primary Emerald "Get Started" button (haptic: `.light`).
- **Accessibility:** VoiceOver label "Onboarding slide 1 of 3".

### Screen 02: Enterprise User Registration & Estate Setup
- **Header:** "Join TeaYield AI Platform" headline.
- **Form Fields:** Floating Text Fields (Full Name: *Bhanuka Bandara*, Corporate Email: *bhanuka@pedroestates.lk*, Estate Dropdown: *Nuwara Eliya High-Grown Estate*), Password Input with Show/Hide toggle.
- **Actions:** Primary Emerald "Create Account" button with inline loading spinner state.

### Screen 03: Face ID Biometric Authentication & Login
- **Header:** Estate Manager / Supervisor Login header.
- **Content:** Corporate Email Input (*bhanuka@pedroestates.lk*), **Face ID Biometric Quick Login button** with visual pulsing scan ring animation.
- **Fallback:** Secondary Button "Sign in with Passcode".
- **Haptics:** Triggers `.success` haptic on biometric match.

### Screen 04: Home Dashboard & Today's Plucking Tasks (iPhone Compact Flow)
- **Header:** Supervisor Profile (Kusal Bandara - Field Superintendent SUP-402, Pedro Estate, Weather Badge: 19.8°C Sunny).
- **Floating Banner:** Active Geofence Arrival Alert Banner ("Arrived at Upper Division Block A — 25 Pluckers Assigned Today").
- **Task List:** Vertical scrollable list of assigned fields with green readiness tags (High NDVI 0.82) and weight targets (850 kg).
- **Empty State:** Custom empty illustration when no plucking tasks remain for today.
- **Bottom Bar:** iPhone TabBar (Tasks, Scanner, Map, Settings).

### Screen 05: On-Device Core ML Shoot Quality Camera Scanner
- **Viewfinder:** 60fps Full-Screen Camera Viewfinder.
- **AI Overlay:** Green Bounding Box Overlay ("88% Fine Leaf — Two Leaves and a Bud"), status pill ("Status: Optimal Harvest Window").
- **Actions:** Photo capture button, "Save Scan to Offline Storage" button.
- **Haptics:** Triggers `.success` haptic notification on >85% fine leaf detection.

### Screen 06: Spatial Polygon Map & Geofence Explorer
- **Map Canvas:** MapKit Satellite View displaying color-coded field polygons (Green: Block A Peak, Red: Block C Rest, Yellow: Block B Mid).
- **GPS Marker:** Blue location dot tracking supervisor Kusal's position.
- **Callout Card:** Interactive floating card showing Block A acreage (12.50 Acres), predicted yield (850 kg), and supervisor distance (15 meters).

### Screen 07: Executive NavigationSplitView Dashboard (iPad Regular Flow)
- **Column 1 (Sidebar):** Estate Fields List with search bar, NDVI status filters (Peak, Growing, Rest), and estate selector (*Pedro Estate*).
- **Column 2 (Content):** High-Res Satellite Heatmap Canvas displaying dynamic NDVI gradient overlays (0.0 to 1.0).
- **Column 3 (Detail):** Selected Block A Executive Detail Pane showing yield summaries (850 kg target) and plucking readiness index.

### Screen 08: Swift Charts Yield Forecast Analytics & Factory Monitor
- **Top Chart:** **BarMark & LineMark Swift Charts** comparing 7-day predicted yields vs historical actuals across Block A through D.
- **Gauge 1:** Factory Withering Intake Capacity Gauge (2,450 / 3,000 kg - Safe Intake Range).
- **Gauge 2:** Weather trend graph (Rainfall 0.2mm vs Temp 19.8°C).

### Screen 09: Genetic Algorithm Roster Generator & PDF Export
- **Controls:** Plucker Capacity Slider (e.g. 60 Workers), Dynamic Shift Picker (5-Day / 6-Day / 7-Day Cycle), Rest Cycle Picker (7 Days).
- **Action:** Primary "Generate Optimized Roster" button with AI pulse loading state.
- **Grid Table:** Generated worker allocation grid mapping Plucker Groups to Fields across Monday to Saturday.
- **Export Toolbar:** "Export Roster (PDF/CSV)" action button (haptic: `.heavy`).

### Screen 10: Manager Profile, Settings & Offline Sync Manager
- **Content:** User profile card (Bhanuka Bandara - Senior Estate Manager MGR-082), Supabase sync status ("Last Synced: 2 mins ago"), local offline cache storage stats (4 pending records), VoiceOver toggle, Dynamic Type text scale preview.
- **Actions:** "Sync Now" button, Logout button.

---

## 6. Unified Responsive Layout Adaptation Rules

```
+------------------------------------+---------------------------------------------------+
|     COMPACT LAYOUT (iPhone < 600pt)|          REGULAR LAYOUT (iPad > 600pt)            |
+------------------------------------+---------------------------------------------------+
| NavigationStack (Single Column)    | NavigationSplitView (Sidebar + Content + Detail)  |
| Bottom TabBar Navigation           | Permanent Sidebar Navigation                      |
| Single Column LazyVStack Cards     | 2-3 Column Responsive LazyVGrid                   |
| Full Screen Sheet Modals           | Embedded Detail Pane                              |
+------------------------------------+---------------------------------------------------+
```

---

## 7. Interactive Prototype Wireframe Flow Map

```
[Screen 01: Onboarding] ──> [Screen 02: Register] ──> [Screen 03: Face ID Login]
                                                              │
                 ┌────────────────────────────────────────────┴────────────────────────────────────────────┐
                 ▼ (Role: Supervisor)                                                                      ▼ (Role: Manager)
       [Screen 04: Tasks Home]                                                                   [Screen 07: iPad SplitView]
          │          │                                                                                      │
          ▼          ▼                                                                                      ▼
    [Screen 05]   [Screen 06]                                                                      [Screen 08: Analytics]
   (CoreML Scan) (MapKit Map)                                                                               │
          │          │                                                                                      ▼
          └──────────┴────────────────────────> [Screen 10: Settings] <───────────────────────────── [Screen 09: GA Roster]
```

# DESIGN.md — Product Look & Feel Specification
# Product: TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform

## 1. Product Identity & Core Aesthetics
- **Platform Name:** TeaYield AI
- **Platform Type:** Enterprise Precision Agriculture Platform (Native iOS & iPadOS)
- **Design Philosophy:** Apple Human Interface Guidelines (HIG), Glassmorphism / Materials (`.ultraThinMaterial`), High-Contrast Outdoor Legibility, Minimalist Agricultural Elegance.
- **Target Profiles:** 
  - Field Superintendents (Outdoor Mobile iPhone Workflow)
  - Estate Managers (Indoor Executive iPad Desktop Workflow)

---

## 2. Color Palette & Dynamic Theme Tokens

### Light & Dark Mode Tokens
- `Primary Emerald`: `#059669` (Light) / `#10B981` (Dark) — Represents peak harvest readiness (High NDVI 0.75-0.85) and primary actions.
- `Secondary Amber`: `#D97706` (Light) / `#F59E0B` (Dark) — Represents mid-growth phase (Harvest ready in 3-5 days) and warnings.
- `Rest Crimson`: `#DC2626` (Light) / `#EF4444` (Dark) — Represents field rest periods (Do not pluck) and severe rain alerts.
- `Background Canvas`: `#F9FAFB` (Light) / `#111827` (Dark) — Primary view canvas.
- `Surface Glass`: `rgba(255, 255, 255, 0.75)` (Light) / `rgba(31, 41, 55, 0.75)` (Dark) — Floating cards (`.ultraThinMaterial`).
- `Text High-Emphasis`: `#111827` (Light) / `#F9FAFB` (Dark).
- `Text Medium-Emphasis`: `#4B5563` (Light) / `#9CA3AF` (Dark).

---

## 3. Typography & Spacing Foundations
- **Font Family:** Apple SF Pro & SF Pro Display (supporting Dynamic Type).
- **Scale:**
  - Large Title: SF Pro Display Bold 34pt
  - Headline: SF Pro Text Semibold 22pt
  - Body: SF Pro Text Regular 17pt
  - Caption: SF Pro Text Medium 13pt
- **Padding:** 4pt, 8pt, 12pt, 16pt (Standard Card Padding), 24pt, 32pt.
- **Corner Radii:** 8pt (Badges/Buttons), 12pt (Cards), 16pt (Modals), 20pt (iPad Containers).
- **Touch Target:** Minimum 44x44 pt hit area across all interactive controls.

---

## 4. Master Component Library
- **Buttons:** Primary Emerald Solid Button, Secondary Glass Button, Circular Icon Action Button (44x44pt).
- **Cards:** Field Status Glass Card, Floating Geofence Arrival Alert Banner, Task Checklist Card.
- **Badges & Pills:** Readiness Badge (Peak Green / Mid Yellow / Rest Red), Face ID Biometric Lock Pill, Offline Cache Toast.
- **Form Controls:** Dynamic Segmented Pickers (5-Day / 6-Day / 7-Day Cycle), Plucker Capacity Slider, Floating Text Fields.
- **Navigation:** iPhone Bottom TabBar (4 Tabs), iPad `NavigationSplitView` 3-Column Sidebar, Top Bar with Profile Avatar.

---

## 5. Responsive Multi-Device Adaptation
- **iPhone Compact Layout (< 600pt):** Single-column stack navigation (`NavigationStack`), bottom TabBar, vertical scrollable cards.
- **iPad Regular Layout (> 600pt):** Desktop-class 3-column `NavigationSplitView` (Sidebar -> Content Canvas -> Detail Pane), 2-3 column responsive grid (`LazyVGrid`), interactive heatmaps, Swift Charts analytics.

---

## 6. Real-World Domain Data Dictionary (Synchronized with Core Engine)
- **Estate:** Nuwara Eliya High-Grown Estate (Pedro Estate, Upper Division - ID: `3b241101-5231-4822-a982-f87c126d4001`)
- **Fields (PostGIS Spatial Polygons):**
  - Upper Division Block A (`7c9e6679-7425-40de-944b-e07fc1f90ae7`): 12.50 Acres, Peak NDVI: 0.820, Status: READY
  - Middle Valley Block B (`8d1f7780-8536-41ef-055c-f18fd2a01bf8`): 15.00 Acres, Mid NDVI: 0.740, Status: GROWING
  - Lower Ravine Block C (`9e2a8891-9647-42f0-166d-a29fe3b12ca9`): 9.80 Acres, Rest NDVI: 0.580, Status: RESTING
  - High Peak Ridge Block D (`a34b9902-0758-4301-277e-b30af4c23db0`): 18.20 Acres, NDVI: 0.690, Status: GROWING
- **Users:**
  - Kusal Bandara (Field Superintendent, SUP-402)
  - Bhanuka Bandara (Senior Estate Manager, MGR-082)
- **Pluckers (Workforce Registry):**
  - EMP-4012: K. Meenakshi (Average: 27.5 kg/day)
  - EMP-4013: S. Kamalasani (Average: 24.8 kg/day)
  - EMP-4014: R. Thavamani (Average: 26.2 kg/day)
  - EMP-4016: P. Vijaya (Average: 28.5 kg/day)
- **Operational Metrics:**
  - Peak NDVI: 0.820, Daily Factory Withering Trough Capacity: 3,000 kg
  - Fine Leaf Quality Target: 88% Fine Leaf ("Two Leaves and a Bud" Standard)
  - Weather Telemetry: 19.8°C Sunny, Humidity 78%, Rainfall 0.2mm

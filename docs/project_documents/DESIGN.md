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
- **Badges & Pills:** Readiness Badge (🟢 Peak Green / 🟡 Mid Yellow / 🔴 Rest Red), Face ID Biometric Lock Pill, Offline Cache Toast.
- **Form Controls:** Dynamic Segmented Pickers (5-Day / 6-Day / 7-Day Cycle), Plucker Capacity Slider, Floating Text Fields.
- **Navigation:** iPhone Bottom TabBar (4 Tabs), iPad `NavigationSplitView` 3-Column Sidebar, Top Bar with Profile Avatar.

---

## 5. Responsive Multi-Device Adaptation
- **iPhone Compact Layout (< 600pt):** Single-column stack navigation (`NavigationStack`), bottom TabBar, vertical scrollable cards.
- **iPad Regular Layout (> 600pt):** Desktop-class 3-column `NavigationSplitView` (Sidebar -> Content Canvas -> Detail Pane), 2-3 column responsive grid (`LazyVGrid`), interactive heatmaps, Swift Charts analytics.

---

## 6. Real-World Domain Data Dictionary
- **Estate:** Pedro Estate, Nuwara Eliya — Upper Division
- **Fields:** Field 01 (Block A - 12.5 Acres), Field 02 (Block B - 8.0 Acres), Field 03 (Block C - 15.2 Acres)
- **Users:** Kusal Bandara (Field Superintendent SUP-402), Bhanuka Bandara (Senior Estate Manager MGR-082)
- **Metrics:** Peak NDVI `0.82`, Daily Target `850 kg`, Fine Leaf Quality `88% (Two Leaves and a Bud)`, Weather `24°C Sunny, Humidity 78%`, Factory Intake `1,350 / 1,500 kg (90%)`.

# Component 5 Specification: Above & Beyond — Multi-Device Adaptation & Architecture
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 25% (Maximum Weightage Component)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Module:** iOS Application Development — BSc (Hons) Computing (BSCCOMP25.1P)  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  
**Status:** Complete Advanced Polish & Architecture Spec  

---

## 1. Multi-Device Design & Adaptation Strategy (LO1 Requirement)

To claim the maximum 25% weightage under Component 5, TeaYield AI implements a fully responsive, adaptive design across both **iPhone (Compact Size Class)** and **iPad (Regular Size Class)** screens.

### 1.1 Device Experience Matrix

```
+------------------------------------+---------------------------------------------------+
|     IPHONE SUPERVISOR MOBILE MODE  |           IPAD ESTATE MANAGER DESKTOP SUITE       |
|       (Compact Size Class)         |                 (Regular Size Class)              |
+------------------------------------+---------------------------------------------------+
| Single-column stack navigation     | Multi-column NavigationSplitView                  |
| Bottom TabBar navigation           | Persistent Sidebar with field search & filters    |
| Mobile Camera Viewfinder           | Multi-pane Split Screen (Heatmap + Swift Charts)   |
| Geofence Alert Push Notifications  | Interactive Roster Generator & PDF/CSV Exporter   |
+------------------------------------+---------------------------------------------------+
```

### 1.2 Adaptive Layout Implementation Blueprint
```swift
import SwiftUI

struct AdaptiveMainAppShell: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone Supervisor Flow: TabBar Shell
            iPhoneSupervisorTabBar()
        } else {
            // iPad Manager Flow: NavigationSplitView Desktop Shell
            iPadManagerSplitView()
        }
    }
}

struct iPadManagerSplitView: View {
    @State private var selectedField: TeaField?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar Pane
            FieldSidebarListView(selectedField: $selectedField)
                .navigationTitle("Pedro Estate Fields")
        } content: {
            // Content Pane: MapKit Heatmap Canvas
            InteractiveHeatmapCanvas(selectedField: selectedField)
        } detail: {
            // Detail Pane: Yield Charts & GA Roster Controls
            if let field = selectedField {
                FieldDetailExecutivePane(field: field)
            } else {
                ContentUnavailableView("Select a Field", systemImage: "map", description: Text("Select a field from the sidebar to inspect predicted yields and generate schedules."))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```

---

## 2. Advanced Architecture & Dependency Injection Container

### 2.1 Dependency Injection (DI) Container Pattern
TeaYield AI completely decouples view models from concrete services using an `AppContainer` protocol, enabling zero tight coupling and clean mock injection for unit testing.

```swift
protocol AppContainerProtocol {
    var dataRepository: DataRepositoryProtocol { get }
    var apiService: APIServiceProtocol { get }
    var locationService: LocationServiceProtocol { get }
}

final class AppContainer: AppContainerProtocol {
    static let shared = AppContainer()
    
    let dataRepository: DataRepositoryProtocol
    let apiService: APIServiceProtocol
    let locationService: LocationServiceProtocol
    
    private init() {
        self.dataRepository = CoreDataRepository()
        self.apiService = CloudAPIService()
        self.locationService = CoreLocationManager()
    }
}
```

---

## 3. UI/UX Polish, Micro-Interactions & Haptics

### 3.1 Custom Matched Geometry Animations
When an Estate Manager selects a field card, the view transitions smoothly into a full-screen yield analytics detail pane using SwiftUI's `.matchedGeometryEffect`.

### 3.2 Haptic Feedback Matrix (`UIImpactFeedbackGenerator`)
- **Successful Shoot Scan:** Triggers `.success` haptic notification when the camera detects >85% fine leaf quality.
- **Geofence Entry:** Triggers `.medium` impact haptic upon entering a field scheduled for plucking today.
- **Roster Export:** Triggers `.heavy` impact haptic when the Genetic Algorithm finishes roster optimization.

### 3.3 Offline Network Fallback Banner
When the device is offline in remote mountain fields, a subtle top banner displays: *"Offline Mode — Caching scans to Core Data"*, smoothly disappearing when network connection is restored.

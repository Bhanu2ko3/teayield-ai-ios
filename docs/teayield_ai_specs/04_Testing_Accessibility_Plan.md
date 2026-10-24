# Component 4 Specification: Swift Testing, Accessibility & Documentation
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 15% (Elective / Max Marks)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Module:** iOS Application Development — BSc (Hons) Computing (BSCCOMP25.1P)  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  
**Status:** Complete QA & Documentation Spec  

---

## 1. Swift Testing Framework Test Suite (`import Testing`)

> [!IMPORTANT]
> **Testing Mandate:** Must use Apple's modern **Swift Testing framework** (`import Testing`, `@Test`, `#expect`), NOT legacy XCTest syntax.

### 1.1 Test Suite Matrix & Target Coverage
- [x] **`FieldMapViewModelTests`:** Validates GeoJSON polygon parsing, NDVI color-coding transformations, and field selection logic.
- [x] **`YieldAnalyticsViewModelTests`:** Tests prediction sorting, historical yield comparisons, and unit conversion (kg to tons).
- [x] **`RosterViewModelTests`:** Validates Genetic Algorithm parameter inputs (worker count, dynamic shift days) and constraint validation.
- [x] **`MockDataRepositoryTests`:** Tests offline Core Data CRUD persistence, fallback error handling, and network failure resilience.

### 1.2 Executable Swift Testing Blueprint
```swift
import Testing
@testable import TeaYieldAI

struct FieldMapViewModelTests {

    @Test("ViewModel correctly categorizes field readiness based on NDVI value")
    func testFieldNDVIReadiness() throws {
        let fieldHighNDVI = TeaField(id: UUID(), name: "Pedro Field 01", ndvi: 0.82)
        let fieldLowNDVI = TeaField(id: UUID(), name: "Pedro Field 02", ndvi: 0.52)
        
        #expect(fieldHighNDVI.readinessCategory == .peakHarvest)
        #expect(fieldLowNDVI.readinessCategory == .restPeriod)
    }

    @Test("Roster ViewModel validates worker capacity constraints before API call")
    func testRosterConstraintValidation() throws {
        let viewModel = RosterViewModel()
        viewModel.availableWorkers = 0 // Invalid constraint
        
        let isValid = viewModel.validateConstraints()
        
        #expect(isValid == false)
        #expect(viewModel.validationErrorMessage == "Worker count must be greater than zero")
    }

    @Test("Mock Data Repository handles offline Core Data fallback seamlessly")
    func testOfflineDataFallback() async throws {
        let mockRepo = MockDataRepository(shouldSimulateNetworkFailure: true)
        let viewModel = YieldAnalyticsViewModel(repository: mockRepo)
        
        await viewModel.fetchWeeklyPredictions()
        
        #expect(viewModel.isUsingOfflineCachedData == true)
        #expect(viewModel.predictedYields.isEmpty == false)
    }
}
```

---

## 2. Accessibility Compliance Audit (100% Support)

### 2.1 VoiceOver Accessibility Blueprint
Every interactive UI control, satellite map overlay, and camera viewfinder element is annotated with descriptive accessibility metadata for field supervisors.

```swift
// Camera Scanner Viewfinder Accessibility
Image(systemName: "camera.viewfinder")
    .accessibilityLabel("Tea Shoot Camera Scanner")
    .accessibilityHint("Point camera at tea leaves to analyze bud and leaf quality ratio")
    .accessibilityAddTraits(.isImage)

// Geofence Status Badge Accessibility
HStack {
    Circle().fill(Color.emerald)
    Text("Field 01 - Scheduled Today")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Field 01 status: Scheduled for harvesting today")
```

### 2.2 Dynamic Type Font Scaling
- Replaces hardcoded pixel font sizes with semantic text styles (`.font(.largeTitle)`, `.font(.headline)`, `.font(.body)`).
- Container layouts utilize `ScrollView` and flexible `VStack(alignment: .leading)` wrappers to prevent text clipping when users expand system text size.

---

## 3. Learning Outcomes (LO1–LO4) Reflection Matrix
*(Integrated into Section 4 of the 4-Page Final Report PDF)*

| Learning Outcome | Description | TeaYield AI Specific Evidence & Justification |
| :--- | :--- | :--- |
| **LO1 — Multi-Device Adaptation** | Critically evaluate platform components across devices | Native layout adaptation for iPhone (single column compact flow) and iPad (`NavigationSplitView` desktop-class multi-pane executive suite). |
| **LO2 — Mobile Architecture** | Design & evaluate mobile software architecture | Production MVVM architecture, Protocol-Oriented Services, Dependency Injection container, and modular folder separation. |
| **LO3 — External APIs & Services** | Develop apps interacting with external APIs | Integration of Python FastAPI REST backend, Sentinel-2 Satellite API, Open-Meteo Weather API, and Supabase cloud sync. |
| **LO4 — Device Sensors & Hardware** | Develop apps communicating with phone sensors | Apple Silicon Neural Engine (`CoreML`/`Vision`), `CoreLocation` background geofencing, and `LocalAuthentication` Face ID sensors. |

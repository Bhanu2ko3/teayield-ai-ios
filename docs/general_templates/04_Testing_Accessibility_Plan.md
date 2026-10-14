# Component 4 Specification: Swift Testing, Accessibility & Documentation
**Target Weightage:** 15% (Elective / Max Marks)  
**Status:** QA & Documentation Blueprint  

---

## 1. Swift Testing Framework Test Suite (`import Testing`)

> [!IMPORTANT]
> **Framework Requirement:** MUST use Apple's modern **Swift Testing framework** (`import Testing`, `@Test`, `#expect`), NOT legacy XCTest.

### Target Test Coverage Matrix:
- [ ] **ViewModel Logic:** State transitions, user interaction handling, form validations.
- [ ] **Data Repository / Services:** Mock API responses, Core Data CRUD transformations, error handling.
- [ ] **Edge Cases:** Network failure, empty state, corrupt data payload, biometric failure fallbacks.

### Sample Test Blueprint:
```swift
import Testing
@testable import YourAppName

struct ItemViewModelTests {

    @Test("ViewModel successfully fetches records from mock repository")
    func testFetchRecordsSuccess() async throws {
        let mockRepository = MockDataRepository(sampleData: [.mockItem1, .mockItem2])
        let viewModel = ItemViewModel(repository: mockRepository)
        
        await viewModel.fetchItems()
        
        #expect(viewModel.items.count == 2)
        #expect(viewModel.items.first?.title == "Mock Item 1")
    }
    
    @Test("ViewModel handles network error gracefully")
    func testFetchRecordsErrorHandling() async throws {
        let mockRepository = MockDataRepository(shouldFail: true)
        let viewModel = ItemViewModel(repository: mockRepository)
        
        await viewModel.fetchItems()
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.items.isEmpty)
    }
}
```

---

## 2. Accessibility Compliance Audit (100% Support)

### 2.1 VoiceOver Accessibility Matrix
- **Labels & Hints:** Every interactive button, image, and dynamic element MUST have descriptive labels.
  - Example: `.accessibilityLabel("Scan Object")`
  - Example: `.accessibilityHint("Uses camera and Core ML to identify items")`
  - Example: `.accessibilityAddTraits(.isButton)`

### 2.2 Dynamic Type Font Scaling
- Uses relative text styles (`.font(.body)`, `.font(.headline)`, `.font(.title)`) rather than hardcoded point sizes.
- Ensures containers auto-wrap without clipping text when user scales text to accessibility extra-large sizes.

---

## 3. Learning Outcomes (LO1–LO4) Reflection Matrix
*(To be included in Section 4 of the 4-page Final Report PDF)*

| Learning Outcome | Description | App Evidence & Justification |
| :--- | :--- | :--- |
| **LO1** | Platform components across devices | Multi-device layout adaptation for iPhone (single column) and iPad (NavigationSplitView multi-column layout). |
| **LO2** | Mobile architecture design | Clean MVVM pattern, Dependency Injection, Protocol-Oriented Services, modular folder structure. |
| **LO3** | External APIs and devices | Integration of Firebase Firestore / REST API for remote synchronization + Core Data local storage. |
| **LO4** | Device sensors | Core Location GPS tracking, geofencing alert triggers, and LocalAuthentication biometric sensor integration. |

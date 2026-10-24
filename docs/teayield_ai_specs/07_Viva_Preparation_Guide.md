# Component 2 Defense: Viva Preparation Guide & Technical Defense
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** Part of Component 2 (20% Mandatory)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Module:** iOS Application Development — BSc (Hons) Computing (BSCCOMP25.1P)  
**Institution:** National Institute of Business Management (NIBM) / Coventry University  
**Objective:** Prove 100% Student Code Ownership, Architectural Mastery, and Live Problem-Solving Capability during the Live Viva Exam.

---

## 1. Work Product Defense (Proving Code Ownership)

### Key Questions & Model Defense Answers:

1. **Q: Walk me through the exact entry point and architecture of your SwiftUI app.**
   - *Model Answer:* The entry point is `@main struct TeaYieldAIApp: App`. We follow pure MVVM augmented with Protocol-Oriented Services. Views are declarative and thin; `ObservableObject` ViewModels (`@Published`) manage UI state and handle business logic; data services (`CoreDataRepository`, `CloudAPIService`, `OfflineSyncManager`) are injected via the `AppContainerProtocol` dependency injection container. This ensures zero tight coupling, Xcode 14.3.1 / iOS 16.4 backward compatibility, and allows full mock injection during unit testing.

2. **Q: How does your Core Data stack handle background saves without blocking the main UI thread?**
   - *Model Answer:* `NSPersistentContainer` manages main thread reads via `viewContext`. Background saves—such as camera shoot quality scans and background network sync flushes—execute on a separate `newBackgroundContext()` using `perform { ... }`, configured with `automaticallyMergesChangesFromParent = true` so that updates merge seamlessly into the UI thread without UI stutter.

3. **Q: Why did you choose On-Device Core ML over remote cloud LLM/AI APIs for Component 3?**
   - *Model Answer:* Component 3 strictly requires on-device processing. Commercial tea fields in Nuwara Eliya are located in high-altitude mountain valleys with zero cellular connectivity. Remote cloud AI APIs (like OpenAI or Gemini) fail completely in offline conditions, introduce high latency, and incur recurring cloud API expenses. Our on-device `VNCoreMLModel` runs directly on the Apple Silicon Neural Engine at 60fps with zero latency, zero cloud costs, and 100% offline reliability.

4. **Q: Explain how the dual-repository architecture operates and how your iOS client was integrated.**
   - *Model Answer:* The platform is partitioned into `teayield-ai-core` (Python FastAPI cloud intelligence engine and research core) and `teayield-ai-ios` (native Swift client). Under Phase 3 of the backend roadmap, the FastAPI microservice deployed deterministic, agro-ecologically realistic contract stubs matching our Swift `Codable` models. This unblocked our iOS client development early in the project lifecycle, allowing us to build, test, and verify MapKit polygon rendering, Face ID auth, and offline weighing sync without waiting for offline neural network training.

5. **Q: How are user credentials and passwords handled, and why are zero credentials hardcoded in the app?**
   - *Model Answer:* In accordance with enterprise mobile security standards, zero passwords or credentials are hardcoded or stored in the frontend codebase. User-entered credentials are transmitted over HTTPS to `/api/v1/auth/login`. The FastAPI backend validates credentials against the Supabase database and issues an encrypted JWT bearer token. On the client, this token is securely persisted in the hardware iOS Keychain using `kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlock`. Subsequent sessions unlock via Apple Silicon biometric authentication (`LocalAuthentication` Face ID) retrieving the cached Keychain token without storing cleartext passwords in application memory.

---

## 2. Technical Decisions & Architectural Trade-Offs

1. **Q: Why did you choose Supabase (PostGIS) and Python FastAPI over Firebase?**
   - *Model Answer:* Traditional BaaS platforms like Firebase Firestore lack native geospatial polygon query capabilities. Supabase provides native PostgreSQL with PostGIS spatial extensions, enabling sub-millisecond point-in-polygon containment checks (`ST_Contains`) and centroid calculations. Python FastAPI seamlessly hosts our PyTorch temporal LSTM neural network and DEAP Genetic Algorithm optimizer libraries with high-performance asynchronous execution.

2. **Q: How does your geofencing system avoid draining the iPhone battery?**
   - *Model Answer:* We avoid continuous high-accuracy GPS polling. Instead, we use `CoreLocation` background circular region monitoring (`CLCircularRegion`). It delegates boundary monitoring to the hardware motion coprocessor, waking the main iOS app only when the supervisor crosses registered field polygon boundaries.

3. **Q: How does your store-and-forward offline synchronization handle network dropouts and duplicate records?**
   - *Model Answer:* Each weighing record generated on the field supervisor's device receives an idempotent client-generated UUID (`localLogId`). If cellular signal is absent, records are saved to Core Data with `isSynced = false`. When `NWPathMonitor` detects connectivity, records are batched into `HarvestSyncBatchDTO` and dispatched to `POST /api/v1/harvest/sync`. The server processes the records and returns `synced_ids`, allowing Core Data to safely mark records as `isSynced = true` without risk of duplicate insertions.

4. **Q: Why did you choose Apple's Swift Testing framework over legacy XCTest for Component 4?**
   - *Model Answer:* Swift Testing (`import Testing`) is Apple's modern testing framework. It uses macro-driven syntax (`@Test`, `#expect`), supports parameterized test matrices, provides richer failure diagnostics without manual string assertions, and integrates cleanly with Swift concurrency.

---

## 3. Live Viva Challenge Preparation

Lecturers frequently request live code modifications during the Viva exam to verify student code ownership. Be prepared to perform:

- **Challenge 1 (UI / Styling):** Change dynamic accent color tokens (e.g., modifying `Color.emerald` or switching Dark Mode card materials from `.ultraThinMaterial` to `.thinMaterial`).
- **Challenge 2 (Accessibility):** Add or adjust a VoiceOver accessibility label or hint on an interactive control (e.g., adding `.accessibilityHint("Scans tea bush for bud-to-leaf ratio")` to the camera viewfinder).
- **Challenge 3 (ViewModel Logic):** Modify a ViewModel validation constraint (e.g., updating the default Genetic Algorithm plucker dynamic shift cycle from 6 days to 5 days, or altering minimum plucker capacity).
- **Challenge 4 (Concurrency):** Explain how `@MainActor` prevents data race conditions during asynchronous API calls and background Core Data merges.

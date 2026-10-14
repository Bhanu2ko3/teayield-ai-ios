# Component 2 Defense: Viva Preparation Guide & Technical Defense
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** Part of Component 2 (20%)  
**Objective:** Prove 100% Student Code Ownership, Architectural Mastery, and Live Problem-Solving Capability during the Live Viva Exam.

---

## 1. Work Product Defense (Proving Code Ownership)

### Key Questions & Model Defense Answers:

1. **Q: Walk me through the exact entry point and architecture of your SwiftUI app.**
   - *Model Answer:* The entry point is `@main struct TeaYieldAIApp: App`. We follow pure MVVM with Protocol-Oriented Services. Views are declarative and thin; `@Observable` ViewModels handle state logic; data services (`CoreDataRepository`, `CloudAPIService`) are injected via the `AppContainer` DI protocol.

2. **Q: How does your Core Data stack handle background saves without blocking the main UI thread?**
   - *Model Answer:* `NSPersistentContainer` manages main thread reads via `viewContext`. Background saves from camera scans or offline network syncs execute on `newBackgroundContext()` using `perform { ... }`, with `automaticallyMergesChangesFromParent = true` to merge updates smoothly into the UI thread.

3. **Q: Why did you choose On-Device Core ML over remote cloud LLM/AI APIs for Component 3?**
   - *Model Answer:* Component 3 strictly requires on-device processing. Remote cloud AI APIs fail in remote mountain tea fields without internet signal, incur high cloud API costs, and violate low-latency requirements. On-device Core ML runs on Apple Silicon Neural Engine with zero latency and 100% offline reliability.

---

## 2. Technical Decisions & Architectural Trade-Offs

1. **Q: Why did you choose Supabase (PostGIS) and Python FastAPI over Firebase?**
   - *Model Answer:* Supabase provides native PostgreSQL PostGIS extensions required for spatial GeoJSON field polygon mapping. Python FastAPI seamlessly hosts our PyTorch LSTM neural network and DEAP Genetic Algorithm optimizer libraries.

2. **Q: How does your geofencing system avoid draining the iPhone battery?**
   - *Model Answer:* We use `CoreLocation` background region monitoring (`CLCircularRegion`). It delegates location tracking to the low-power Apple M-series/A-series Motion Co-Processor, waking the main iOS app ONLY when crossing registered field polygon boundaries.

---

## 3. Live Viva Challenge Preparation

Lecturers frequently request live code modifications during the Viva. Be prepared to perform:
- **Challenge 1:** Change dynamic accent color tokens or adjust a VoiceOver label on a button.
- **Challenge 2:** Modify a ViewModel parameter (e.g., changing the default dynamic shift cycle days from 6 days to 5 days).
- **Challenge 3:** Explain how `@MainActor` prevents data race conditions during async API calls.

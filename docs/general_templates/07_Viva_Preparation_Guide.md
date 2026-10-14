# Component 2 Defense: Viva Preparation Guide & Technical Defense
**Scope:** Live Viva Defense Preparation  
**Objective:** Prove 100% Student Code Ownership, Architectural Mastery, and Live Problem-Solving Capability.

---

## 1. Work Product Defense (Proving Code Ownership)

### Key Questions & Model Answers:
1. **Q: Walk me through the entry point of your SwiftUI application and state management.**
   - *Model Answer:* The entry point is `@main struct YourApp: App`. State management relies on `@State`, `@Binding`, and `@Observable` ViewModels adhering to MVVM.

2. **Q: Why did you choose MVVM over placing logic directly inside SwiftUI Views?**
   - *Model Answer:* Keeping views declarative and thin allows separation of concerns. Business logic in ViewModels can be independently unit-tested using Swift Testing mocks without instantiating UI components.

3. **Q: How does your Core Data stack handle data persistence and background saves?**
   - *Model Answer:* We use `NSPersistentContainer`. Writes occur on `viewContext` or `newBackgroundContext()` with `automaticallyMergesChangesFromParent = true` to prevent UI thread blocking.

---

## 2. Technical Decisions & Trade-Offs

### Key Questions & Model Answers:
1. **Q: Why did you select Core ML over remote cloud LLM APIs for Component 3?**
   - *Model Answer:* Component 3 strictly mandates on-device processing. On-device Core ML inference preserves user privacy, operates completely offline, and delivers zero network latency.

2. **Q: How did you implement biometric authentication fallback?**
   - *Model Answer:* Using `LAContext`. If Face ID / Touch ID fails or is unavailable, we fallback gracefully to device passcode evaluation (`.deviceOwnerAuthentication`).

---

## 3. Live Problem-Solving & Live Code Modifications

- **Common Viva Challenges:**
  - Lecturer asks to change a color theme or add a simple filter in a ViewModel.
  - Lecturer asks to explain a specific Swift closure, `@MainActor` attribute, or `async/await` Task block.

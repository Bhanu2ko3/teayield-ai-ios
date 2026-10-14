# Final Report Template (Component 4 Deliverable)
**Target Format:** 4-Page Structured PDF  
**Weightage:** Part of Component 4 (15%)  
**Mandatory Section:** Learning Outcomes (LO1–LO4) Reflection & LLM Usage Log  

---

## 📄 Page 1: App Overview, Problem Domain & UI Showcases
- **1.1 Executive Summary:**
  - Clear problem statement, target audience, core functionality, and Unique Selling Point (USP).
- **1.2 High-Fidelity UI Showcase:**
  - Screenshots of key screens on both iPhone (compact size class) and iPad (regular size class) showing dark and light modes.
- **1.3 User Flow & Navigation:**
  - Brief description of user journeys and HIG compliance.

---

## 📄 Page 2: System Architecture & Technical Implementation
- **2.1 Architectural Pattern (MVVM + POP):**
  - Diagram showing View -> ViewModel -> Service Protocol -> Concrete Repository.
- **2.2 Local Data Persistence (Core Data / SwiftData):**
  - Entity Relationship (ER) Diagram showing entities (`UserProfile`, `ItemRecord`, etc.) and attribute types.
- **2.3 External API & Remote Synchronization (LO3):**
  - REST API / Firebase Firestore integration details, async/await concurrency, and offline caching strategy.
- **2.4 Biometric Security (Face ID / Touch ID):**
  - `LocalAuthentication` framework integration and passcode fallback mechanism.

---

## 📄 Page 3: Advanced iOS SDK (On-Device) & Engineering Challenges
- **3.1 On-Device AI / Machine Learning (Core ML + Vision):**
  - Explanation of on-device model inference pipeline, input camera/image handling, and zero remote cloud API dependency justification.
- **3.2 MapKit & Geofencing (Core Location):**
  - Dynamic data-driven map pins, `CLCircularRegion` geofencing triggers, and local notification alert dispatching.
- **3.3 Engineering Challenges & Solutions:**
  - Technical obstacles faced during development (e.g. memory management, thread synchronization, layout clipping) and how they were resolved.

---

## 📄 Page 4: Learning Outcomes (LO1–LO4) Reflection & LLM Log

### 4.1 Learning Outcomes Reflection Matrix
| Learning Outcome | Description | Specific App Evidence & Justification |
| :--- | :--- | :--- |
| **LO1 — Multi-Device Adaptation** | Critically evaluate platform components across devices | Detailed justification of iPhone (single column stack) vs iPad (`NavigationSplitView` multi-pane) responsive design choices. |
| **LO2 — Mobile Architecture** | Design & evaluate mobile architectures | Evidenced by MVVM separation, Protocol-Oriented Services, Dependency Injection, and high code modularity. |
| **LO3 — External APIs & Services** | Develop apps interacting with external APIs | Evidenced by mandatory Firebase Firestore / REST API synchronization with local Core Data persistence. |
| **LO4 — Device Sensors & Hardware** | Develop apps communicating with phone sensors | Evidenced by Core Location GPS tracking, Geofencing region monitoring, and Face ID biometric sensor integration. |

### 4.2 Mandatory LLM Usage Log & Academic Integrity Declaration
- **Permitted Scope Log:**
  - Brainstorming prompts & output summary.
  - Documentation outline prompts & output summary.
- **Academic Integrity Declaration:**
  - Formal student declaration confirming 100% of executable Swift/SwiftUI source code was student-authored without LLM code generation tools.

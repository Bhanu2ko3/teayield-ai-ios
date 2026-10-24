# Master Git Branching Strategy & Release Management Protocol
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform (iOS Companion Client)  
**Workspace:** `teayield-ai-ios`  
**Affiliation:** Coventry University (UK) & National Institute of Business Management (Sri Lanka)  
**Programme:** BSc (Hons) in Computing — iOS Application Development (BSCCOMP25.1P)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Target Grade:** 100% / A+ Distinction  
**Companion Core Repository:** `~/BSC-computing/research/teayield-ai-core`  
**Document Status:** Complete Enterprise Engineering Protocol  
**Version:** 1.0.0  

---

## 1. Architectural Philosophy & Governance Standards

To ensure academic auditability, software traceability, and seamless multi-repository synchronization with the companion backend core (`teayield-ai-core`), this mobile client repository enforces a structured **Phase-Aligned Git Flow Branching Protocol** augmented with **Conventional Commits 1.0.0**.

This strategy guarantees:
1. **Traceable Component Progression:** Every coursework component (Components 1 through 6) develops on dedicated, isolated feature branches.
2. **Permanent Production Stability:** The `main` branch maintains an immutable, production-grade Xcode state ready for live viva presentation at any time.
3. **Dual-Repository Contract Alignment:** Release tags synchronize with the companion research backend (`teayield-ai-core`) API contract versions.
4. **Authentic Academic Audit Trail:** Clean, descriptive commit histories demonstrating independent student-authored progress across the semester.
5. **Zero-Defect Quality Gates:** Automated test suites, concurrency safety checks, and accessibility audits must pass before any code merges into integration.

---

## 2. Multi-Branch Topology & Lifecycle Architecture

```
+───────────────────────────────────────────────────────────────────────────────────────────────────+
|                                    GIT FLOW BRANCHING TOPOLOGY                                    |
+───────────────────────────────────────────────────────────────────────────────────────────────────+

  main (Protected / Production Stable / Viva Releases)
  ──────────────────────●────────────────────────────────────────●───────────────────────● (v1.2.0)
                        ▲ (v1.0.0-mobile-app)                    ▲ (v1.1.0-ai-client)    ▲
                        │ Merge Release Tag                      │ Merge Release Tag     │
  release/v1.0.0        │                                        │                       │
  ──────────────────────● (Cut release candidate)                │                       │
                        ▲                                        │                       │
  develop (Active Integration / Staging)                         │                       │
  ────●─────────●───────┴────────────────────────●───────────────┴───────────────────────┴──────────>
      │         ▲                                ▲
      │ Fork    │ PR Squash Merge                │ PR Squash Merge
      ▼         │                                │
  feat/comp-2-mvp-fastapi                        │
  ──────────────●                                │
                                                 │
  feat/comp-3-ondevice-coreml-vision ────────────●
                                                 
  hotfix/v1.0.1-geofence-fix (Emergency Hotfix Branch)
  ──────────────────────────────────────● (Branches from main, back-merges to main and develop)
```

---

## 3. Branch Classifications & Protection Rules

### 3.1 `main` Branch (Production Stable & Marked Viva Build)
- **Role:** Authoritative production branch containing fully tested, peer-reviewed, and validated native iOS application code.
- **Protection Rules:**
  - Direct commits and force pushes (`git push --force`) are strictly prohibited.
  - Merges into `main` occur exclusively via Pull Requests from `release/*` or `hotfix/*` branches.
  - Requires clean compilation on Xcode 15+ with zero warnings.
- **Tagging:** Every merge to `main` generates an immutable Git tag following Semantic Versioning (e.g., `v1.0.0-mobile-app`).

### 3.2 `develop` Branch (Active Integration)
- **Role:** Primary day-to-day integration branch where completed component feature branches converge.
- **Protection Rules:**
  - Direct commits are prohibited for major features; all work merges through pull requests.
  - Must remain in a compiling and test-passing state at the close of every development session.
- **Quality Gate:** All Swift Testing suites (`import Testing`) must pass with 100% green status.

### 3.3 `feat/comp-<number>-<description>` (Component Feature Branches)
- **Role:** Dedicated work branches for specific coursework components.
- **Lifecycle:** Forks from `develop`, undergoes iterative commits, and squash-merges back into `develop` upon satisfying Definition of Done (DoD).
- **Naming Rule:** Hyphen-delimited, lowercase, prefixed with component identifier (e.g. `feat/comp-2-mvp-fastapi-networking`).

### 3.4 `release/v<semantic-version>` (Release Stabilization Branches)
- **Role:** Cut from `develop` when all component features for a milestone are complete. Used exclusively for final UI polish, VoiceOver testing, and viva defense rehearsals.
- **Merge Back:** Merges into `main` (with release tag) and back-merges into `develop` to propagate any final release fixes.

### 3.5 `hotfix/v<semantic-version>-<description>` (Critical Hotfix Branches)
- **Role:** Cut directly from `main` to address critical viva-blocking regressions (e.g. MapKit runtime crash or Face ID fallback issue).
- **Merge Back:** Merges simultaneously into `main` (with patch tag) and `develop`.

### 3.6 `test/<scope>-<description>` & `docs/<scope>-<description>`
- **Role:** Isolated branches for adding Swift Testing suites, accessibility audits, or updating coursework specifications without touching business logic.

---

## 4. Coursework Component Branching Matrix

To prevent branch fragmentation, development follows a clean, single-branch-per-component milestone strategy:

| Component | Target Branch Name | Deliverable & Functional Scope | Base Branch | Target Branch |
| :--- | :--- | :--- | :--- | :--- |
| **Component 1** | `feat/comp-1-proposal-figma` | App proposal document, HIG design tokens, and 10-screen interactive Figma prototype. | `main` | `develop` |
| **Component 2** | `feat/comp-2-mvp-core` | Complete MVP: `URLSession` networking, FastAPI DTOs, Core Data offline caching, and Face ID auth. | `develop` | `develop` |
| **Component 3** | `feat/comp-3-advanced-sdk` | On-device Core ML Vision 60fps leaf scanner and MapKit spatial vector polygons with geofencing. | `develop` | `develop` |
| **Component 4** | `feat/comp-4-qa-a11y-report` | Apple Swift Testing suites (`@Test`, `#expect`), 100% VoiceOver accessibility audit, and 4-page final report PDF. | `develop` | `develop` |
| **Component 5** | `feat/comp-5-ipad-suite` | Desktop-class 3-column `NavigationSplitView`, Swift Charts yield analytics, `AppContainer` DI, and micro-haptics. | `develop` | `develop` |

> *Note on Component 6:* In-Class Tutorial 4 (PlayHubApp) is a standalone laboratory coursework project submitted and evaluated via its own dedicated repository. It is excluded from the TeaYield AI companion client branching model.

---

## 5. Commit Message Standard (Conventional Commits 1.0.0)

All commit messages must strictly adhere to the Conventional Commits specification to guarantee academic auditability.

### 5.1 Format Structure
```
<type>(<scope>): <short imperative subject summary>

<detailed body paragraph explaining rationale and technical decisions>

<footer references, component IDs, or breaking change declarations>
```

### 5.2 Permitted Types
- **`feat`:** Introduces a new SwiftUI view, view model, service, or functionality.
- **`fix`:** Corrects a runtime bug, concurrency data race, or visual layout glitch.
- **`docs`:** Updates documentation, specifications, or academic reports.
- **`style`:** Code formatting, whitespace, or naming cleanups with zero logic change.
- **`refactor`:** Code restructuring without adding features or fixing bugs (e.g., protocol extraction).
- **`perf`:** Performance optimization (e.g., `CVPixelBuffer` pool management, lazy rendering).
- **`test`:** Introduces or updates Swift Testing suites (`import Testing`) or mock repositories.
- **`chore`:** Xcode build settings, SPM package dependency updates, or git maintenance.

### 5.3 Permitted Scopes
`comp1`, `comp2`, `comp3`, `comp4`, `comp5`, `coredata`, `networking`, `vision`, `mapkit`, `charts`, `auth`, `a11y`, `navigation`.

### 5.4 Mandatory Quality Directives
1. **Imperative Mood:** Use "Add ViewModel" rather than "Added ViewModel" or "Adds ViewModel".
2. **Character Limit:** Subject line must not exceed 72 characters.
3. **Strict Zero Emojis:** Commit messages must be 100% free of decorative emojis.
4. **Authentic Student Voice:** Commit descriptions must reflect clear, independent student thought and engineering rationale.

---

## 6. GitHub Branch Protection & Security Governance Rules

To safeguard codebase integrity in accordance with enterprise software engineering standards:

```
+───────────────────────────────────────────────────────────────────────────────────────────────────+
|                                  BRANCH PROTECTION CONFIGURATION                                  |
+───────────────────────────────────────────────────────────────────────────────────────────────────+
| Target Branches: main, develop                                                                    |
|                                                                                                   |
| [x] 1. Require Pull Request before merging (Enforce code reviews).                                 |
| [x] 2. Require status checks to pass before merging:                                              |
|        • xcodebuild test (Swift Testing suite passes with 0 failures).                            |
|        • swift-format lint (Strict Apple Swift style compliance).                                 |
| [x] 3. Require linear commit history (Squash and merge for features, merge commit for releases).   |
| [x] 4. Strictly prohibit force pushes (git push --force disabled).                                |
| [x] 5. Strictly prohibit branch deletions on main and develop.                                    |
| [x] 6. Confidential AI configuration (.agents/) strictly excluded by .gitignore.                 |
+───────────────────────────────────────────────────────────────────────────────────────────────────+
```

---

## 7. Automated Quality Gates & CI/CD Pipeline Blueprint

Every pull request targeting `develop` or `main` triggers automated verification via Xcode Cloud or GitHub Actions:

```yaml
# .github/workflows/ios-ci.yml
name: TeaYield AI iOS CI Quality Gate

on:
  pull_request:
    branches: [ develop, main ]
  push:
    branches: [ develop, main ]

jobs:
  build-and-test:
    name: Xcode Build & Swift Testing Suite
    runs-on: macos-14
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v4

      - name: Select Xcode 15.4
        run: sudo xcode-select -s /Applications/Xcode_15.4.app

      - name: Build and Test Scheme
        run: |
          xcodebuild test \
            -scheme TeaYieldAI \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
            -enableCodeCoverage YES \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO
```

---

## 8. Pull Request & Merging Protocol

Before any component branch merges into `develop`, the following quality gate checklist must be verified:

```
+───────────────────────────────────────────────────────────────────────────────────────────────────+
|                                    PULL REQUEST QUALITY CHECKLIST                                 |
+───────────────────────────────────────────────────────────────────────────────────────────────────+
| [x] 1. Clean Xcode build with zero compiler warnings and zero errors.                              |
| [x] 2. All Swift Testing suites pass green (`import Testing`, `#expect`).                         |
| [x] 3. UI-bound ViewModels decorated with `@MainActor` to eliminate data races.                   |
| [x] 4. Core Data operations execute on background contexts (`newBackgroundContext`).               |
| [x] 5. All interactive UI controls contain VoiceOver labels and support Dynamic Type.             |
| [x] 6. Swift Codable models strictly conform to backend FastAPI Pydantic v2 schemas.              |
| [x] 7. Zero decorative emojis in Swift source code, comments, docstrings, or commit messages.     |
| [x] 8. Confidential `.agents/` configuration is 100% excluded by `.gitignore`.                    |
+───────────────────────────────────────────────────────────────────────────────────────────────────+
```

### Merge Strategies
- **Feature to `develop`:** **Squash and Merge** to maintain a clean, linear, readable commit history on `develop`.
- **Release to `main`:** **Merge Commit** with an annotated semantic release tag, preserving milestone integrity.
- **Release back to `develop`:** **Merge Commit** to ensure any release stabilization fixes propagate to integration.

---

## 9. Dual-Repository Version Synchronization Matrix

Because `teayield-ai-core` (backend) and `teayield-ai-ios` (client) operate within a decoupled dual-repository ecosystem, release tags must maintain strict semantic alignment:

| Core Backend Tag (`teayield-ai-core`) | iOS Client Tag (`teayield-ai-ios`) | Integrated Milestone Scope |
| :--- | :--- | :--- |
| `v0.1.0-specs` | `v0.1.0-specs` | Full specifications and architecture finalized across both repos. |
| `v0.2.0-gateway` | `v0.2.0-client-stubs` | FastAPI microservice live with deterministic stubs; iOS networking ready. |
| `v0.3.0-mobile-release` | `v1.0.0-mobile-app` | Native iOS app demonstrable with Core Data, Face ID, Vision, and MapKit. |
| `v0.5.0-ai-integrated` | `v1.1.0-ai-client` | Live LSTM yield prediction and Genetic Algorithm roster sync operational. |
| `v1.0.0-final` | `v1.2.0-final` | Final production build, 4-page report compiled, ready for viva defense. |

---

## 10. Command-Line Reference Cheatsheet

### 10.1 Initializing Integration Branch
```bash
# Verify on main
git checkout main
git pull origin main

# Create and publish develop branch
git checkout -b develop
git push -u origin develop
```

### 10.2 Starting a New Component Feature Branch
```bash
# Ensure develop is updated
git checkout develop
git pull origin develop

# Create and switch to new component feature branch
git checkout -b feat/comp-2-mvp-fastapi-networking
```

### 10.3 Staging and Committing Changes
```bash
# Check modified files
git status

# Stage specific files
git add TeaYieldAI/Services/CloudAPIService.swift TeaYieldAI/Models/DTOs/

# Commit using Conventional Commits format
git commit -m "feat(comp2): implement URLSession networking with FastAPI DTO decoding"
```

### 10.4 Integrating Feature Branch into Develop
```bash
# Switch to develop
git checkout develop
git pull origin develop

# Squash and merge feature branch
git merge --squash feat/comp-2-mvp-fastapi-networking
git commit -m "feat(comp2): complete FastAPI networking and DTO contract integration"

# Delete local feature branch
git branch -d feat/comp-2-mvp-fastapi-networking
```

### 10.5 Creating an Official Milestone Release on Main
```bash
# Cut release branch from develop
git checkout develop
git checkout -b release/v1.0.0

# Final testing and validation...
# Merge into main
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0-mobile-app -m "Release v1.0.0: Complete MVP, On-Device Vision, and Offline Sync"
git push origin main --tags

# Back-merge into develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# Delete release branch
git branch -d release/v1.0.0
```

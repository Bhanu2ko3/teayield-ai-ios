# Component 6 Specification: In-Class Tutorial 4 — "The Real App" (PlayHubApp)
**Target Weightage:** 10% (Elective / Marked Lab Submission)  
**Status:** Complete Tutorial 4 Blueprint  

---

## 1. Project Context & Objectives
- **Context:** Tutorial 4 ("The Real App") refactors and integrates the 3 game modes developed across Tutorials 1–3 (*Tap Frenzy*, *Light It Up*, *Quiz Rush*) into a single, polished app shell named **PlayHubApp**.
- **Submission Requirements:** Completed Xcode project submitted via module Git repository with commit history showing incremental in-lab progress, a README file, and an in-lab check/walkthrough with the lab instructor.

---

## 2. Refactored MVVM Architecture Structure

```
PlayHubApp/
├── App/
│   └── PlayHubApp.swift
├── Models/
│   ├── GameMode.swift
│   ├── GameSession.swift
│   └── TriviaQuestion.swift
├── ViewModels/
│   ├── TapFrenzyVM.swift
│   ├── LightItUpVM.swift
│   ├── QuizRushVM.swift
│   └── StatsVM.swift
├── Services/
│   ├── TriviaAPI.swift
│   ├── NotificationService.swift
│   └── LocationService.swift
└── Views/
    ├── Tabs/
    │   ├── HomeTab.swift
    │   ├── StatsTab.swift
    │   ├── MapTab.swift
    │   └── SettingsTab.swift
    ├── Games/
    │   ├── TapFrenzyView.swift
    │   ├── LightItUpView.swift
    │   └── QuizRushView.swift
    └── Shared/
        ├── ResultView.swift
        └── ScoreBadge.swift
```

---

## 3. Data Model & Storage (`GameSession`)

### `GameSession` Struct Definition:
- `id`: UUID
- `mode`: GameMode (`.tapFrenzy`, `.lightItUp`, `.quizRush`)
- `score`: Int
- `timestamp`: Date
- `latitude`: Double
- `longitude`: Double

### Persistence Strategy:
- Encoded as a JSON array and stored in `UserDefaults.standard` under key `"saved_game_sessions"`.
- Every completed game session appends a new `GameSession` record containing the player's real-time GPS coordinates from `LocationService`.

---

## 4. Feature Implementation Requirements

- [x] **Tab Bar Shell:** `TabView` containing 4 tabs (Home, Stats, Map, Settings) using SF Symbols icons, each wrapped in its own `NavigationStack`.
- [x] **Stats Screen:** Uses Apple's **Charts framework** (`BarMark`) to display game mode statistics, personal best scores, totals, and recent session history.
- [x] **Map of Games:** Combines `MapKit` and `Core Location`. Displays interactive pins for every recorded game session showing location and score on tap.
- [x] **Daily Challenge:** Integrated `UserNotifications` scheduling local notifications based on player-selected daily reminder time in Settings tab.
- [x] **Share Your Score:** Features a `ShareLink` view on the game `ResultView` generating formatted score share strings.
- [x] **Settings Screen:** Contains notification toggle, daily challenge time picker, and a reset-all-stats button with a confirmation `.confirmationDialog`.

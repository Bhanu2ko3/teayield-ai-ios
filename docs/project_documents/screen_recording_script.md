# TeaYield AI — App Demonstration Video Script & Recording Guide

**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Duration:** 3 to 5 Minutes (Optimal Target: ~4 Minutes)  
**Deliverable Type:** Narrated Screen Recording Video (.mp4 / .mov)  
**Author:** Bhanuka Bandara (Student ID: 082 | Coventry ID: 16604375)  
**Document Purpose:** Complete step-by-step recording cue sheet and word-for-word spoken narration script conforming to university anti-AI humanization standards.

---

## 1. Video Recording Setup & Technical Checklist

* **Device Simulators:**
  * Primary: iPhone 14 Pro or 15 Pro (iOS 16.4+)
  * Secondary (For LO1 / Component 5): iPad Pro 11-inch (Landscape)
* **Recording Tool:** QuickTime Player (`File -> New Screen Recording`) or OBS Studio recording at 1080p (60fps).
* **Audio Setup:** External microphone or clear built-in laptop mic. Quiet room with zero background noise.
* **Duration Constraint:** Strictly between 3:00 and 5:00 minutes (matches the LMS requirement: "[3-5] minutes").
* **Speech Tone:** Clear, steady, natural student voice. Speak directly in first-person ("I designed...", "Here I built...", "This runs on..."). Avoid rushing.

---

## 2. Minute-by-Minute Demonstration Cue Sheet

| Time Window | Screen Action (What Markers See) | Spoken Focus (What You Say) | Coursework Rubric Evidence |
| :---: | :--- | :--- | :--- |
| **0:00 – 0:40** | App icon launch -> Onboarding slides swipe -> Login view with Face ID biometric prompt | Introduction, student identity, problem context, biometric authentication | **Component 1 & Component 2** (Onboarding & Face ID Auth) |
| **0:40 – 1:30** | Today's Tasks tab -> Select task -> Digital Scale Harvest Weighing form -> Add weight -> Save | Supervisor task management, green leaf weighing, Core Data offline caching | **Component 2** (Core Data Persistence & MVP Workflow) |
| **1:30 – 2:20** | Leaf Scanner tab -> Point at sample tea shoot -> Real-time HUD overlay (88% Fine Leaf) | On-device Core ML Vision model, 60fps Neural Engine inference, SLTB 85% benchmark | **Component 3** (On-Device Core ML, Zero Cloud AI) |
| **2:20 – 3:00** | Map tab -> Spatial vector field polygons (`MKPolygon`) -> Simulate entering field -> Geofence arrival alert banner | MapKit spatial GIS, vegetative NDVI color codes, low-power `CLCircularRegion` geofencing | **Component 3 & Component 2** (MapKit GIS & Local Notifications) |
| **3:00 – 3:45** | Switch to iPad Simulator -> Manager login -> 3-column `NavigationSplitView` -> Swift Charts -> PDF Export | Desktop-class iPad adaptation, Swift Charts analytics, Roster PDF report generation | **Component 5 & LO1** (Multi-Device Design & Above & Beyond) |
| **3:45 – 4:20** | Home Screen WidgetKit -> Settings tab -> Store-and-Forward Offline Sync -> Trigger sync -> Conclusion | WidgetKit integration, `NWPathMonitor` auto-sync to FastAPI backend, final wrap-up | **Component 5 & LO3** (External API & Platform Polish) |

---

## 3. Word-for-Word Spoken Narration Script

> [!NOTE]
> Read this text aloud at a steady, natural pace. You can use your own natural phrasing, but keep the technical terms accurate.

### Scene 1: Introduction, Onboarding & Biometric Login (0:00 – 0:40)
*(Screen: App launches from home screen, showing the custom TeaYield AI green leaf icon, then lands on the Onboarding Carousel)*

> "Hello. My name is Bhanuka Bandara, student ID 082, Coventry ID 16604375. This is the demonstration of my iOS coursework application, TeaYield AI.  
> 
> Tea estates in Nuwara Eliya face major losses because supervisors manually guess harvest dates and pluckers mix coarse leaves with tender buds. TeaYield AI solves this using free satellite data, on-device AI, and automated scheduling.  
> 
> As you see here, the app starts with a three-slide onboarding carousel introducing satellite NDVI yield prediction and offline sync. Once I tap 'Get Started', we reach the login screen.  
> 
> I built biometric authentication into this screen using LocalAuthentication. When I tap the Face ID button, the system authenticates me and unlocks the session using the secure token saved in the iOS Keychain."

---

### Scene 2: Field Supervisor Daily Tasks & Harvest Weighing (0:40 – 1:30)
*(Screen: App enters Supervisor 4-Tab Workspace, landing on Today's Tasks)*

> "Now we are in the field supervisor workspace. The first tab shows Today's Tasks. It pulls assigned field blocks and target green leaf weights for today's shift.  
> 
> When workers bring their harvest bags to the field weighing point, the supervisor taps 'Record Harvest'. This opens my digital weighing form.  
> 
> Here, I can select the plucker from the workforce registry, pick the current field block, and enter the gross bag weight. Let's record 24.5 kilos.  
> 
> Notice the sync badge in the corner. Because tea fields in mountain valleys have no cellular coverage, this record saves immediately into my local Core Data SQLite store using a background context. It will sync to our Python FastAPI server as soon as connection returns."

---

### Scene 3: On-Device Core ML Leaf Quality Scanner (1:30 – 2:20)
*(Screen: Supervisor taps the 'Scanner' tab. Camera viewfinder opens with HUD overlay pointed at a tea shoot)*

> "Next is my primary Component 3 advanced feature: our on-device leaf maturity scanner.  
> 
> In traditional estates, pluckers pick overgrown, coarse leaves to make their bags heavier. This ruins the tea quality and drops export auction prices from five dollars to one fifty a kilo.  
> 
> I trained a MobileNetV3 convolutional neural network on real field images and converted it into Core ML. It runs one hundred percent on-device on the Apple Silicon Neural Engine at sixty frames per second. There are zero remote cloud AI API calls here.  
> 
> As I point the camera at this tea shoot, the Vision framework classifies the leaf emergence age across four stages. It calculates the Fine Leaf ratio. Right now, it detects 88% Fine Leaf, passing the Sri Lanka Tea Board 85% export standard. The supervisor can tap 'Apply to Weighing' to attach this quality score directly to the plucking record."

---

### Scene 4: MapKit Spatial GIS Polygons & Geofencing (2:20 – 3:00)
*(Screen: Supervisor taps the 'Map' tab. MapKit satellite view appears with color-coded polygons)*

> "Moving to the Map tab, this is my second advanced SDK feature. I integrated MapKit with Core Location to show estate division blocks as vector polygon overlays.  
> 
> The polygons are dynamically color-coded by satellite NDVI vegetative health. Green means peak harvest readiness, amber means maturing, and red means the field is in its rest cycle.  
> 
> I also built low-power circular geofencing using Core Location. When a supervisor walks into an assigned field boundary, the motion coprocessor detects region entry and triggers a local push notification. Let's trigger a field arrival simulation. You can see the notification banner alert appear right at the top."

---

### Scene 5: iPad Desktop-Class Executive Suite & Analytics (3:00 – 3:45)
*(Screen: Switch video to iPad Simulator running Manager Account in landscape orientation)*

> "Now, to demonstrate Learning Outcome 1 and Component 5 Above and Beyond, I designed a tailored multi-device experience. Here is the Estate Manager Suite on iPad.  
> 
> Instead of the compact iPhone tab bar, I used iOS 16 NavigationSplitView to create a desktop-class three-column layout.  
> 
> In the detail pane, I used the Apple Charts framework. This interactive chart compares our seven-day LSTM predicted yield against verified field weigh-ins. Below it, managers can check the factory intake capacity gauge to make sure incoming leaf volume will not cause withering bottlenecks.  
> 
> Managers can also tap 'Export Roster PDF'. I built a custom PDF graphics renderer that generates an official printable shift sheet, complete with plucker allocations and QR validation codes."

---

### Scene 6: WidgetKit, Store-and-Forward Offline Sync & Wrap-Up (3:45 – 4:20)
*(Screen: Briefly show iOS Home Screen with TeaYield AI Widget, then open Settings tab in the app)*

> "On the iOS home screen, I added a WidgetKit extension showing live estate intake progress and next harvest fields without needing to open the app.  
> 
> Finally, returning to the app's Settings, here is our store-and-forward sync manager. It uses NWPathMonitor. When the device reconnects to Wi-Fi or mobile data, it batches all offline records and sends them to our Python FastAPI endpoint. When I tap 'Sync Now', our cached weigh-ins upload, and the server validates them using PostGIS spatial checks.  
> 
> In summary, TeaYield AI combines clean MVVM architecture, Core Data offline persistence, on-device Neural Engine machine learning, MapKit GIS geofencing, and responsive multi-device design.  
> 
> Thank you very much."

---

## 4. Post-Recording Quality Review Checklist

Before uploading the video to the LMS:
- [ ] Video duration is between 3:00 and 5:00 minutes.
- [ ] Student name and student ID are clearly spoken in the first 15 seconds.
- [ ] Voice audio is crisp, audible, and easily understood.
- [ ] Screen resolution is sharp (1080p, text and numbers are readable).
- [ ] Both iPhone supervisor flow and iPad manager layout are demonstrated.
- [ ] Core ML scanner HUD, MapKit polygon overlays, and offline sync badge are clearly visible.

# Component 5 Specification: Above & Beyond - Multi-Device Adaptation & Architecture
**Target Weightage:** 25% (Maximum Weightage Component)  
**Status:** Advanced Polish Blueprint  

---

## 1. Multi-Device Responsive Design Strategy (LO1)

To claim the maximum marks under Component 5, the application must natively adapt between **iPhone** and **iPad** device profiles.

### Layout Adaptation Matrix:
```
+------------------------------------+---------------------------------------------------+
|            IPHONE LAYOUT           |                    IPAD LAYOUT                    |
+------------------------------------+---------------------------------------------------+
| Single Column Stack Navigation     | Multi-Column NavigationSplitView                  |
| Bottom TabBar                      | Sidebar Navigation List                           |
| Vertical Cards Stack               | Adaptive Grid Columns (LazyVGrid 2-3 columns)     |
| Modal Sheet Details                | Permanent Detail View Pane                        |
+------------------------------------+---------------------------------------------------+
```

### Technical Implementation:
```swift
struct AdaptiveMainView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone Compact View Flow (TabBar + NavigationStack)
            iPhoneTabShell()
        } else {
            // iPad Regular View Flow (NavigationSplitView Sidebar + Detail)
            iPadSidebarShell()
        }
    }
}
```

---

## 2. Advanced Architecture & Dependency Injection

- **MVVM-C (Coordinator Pattern) / Dependency Container:**
  - Services are registered in an `AppContainer` protocol.
  - Zero concrete class coupling; all ViewModels accept protocol abstractions.
- **Offline First Strategy:**
  - Cache database writes locally in Core Data.
  - Background worker pushes cached mutations to Firebase/REST backend when network returns.

---

## 3. UI/UX Polish & Micro-Interactions
- **Custom Animations:** Smooth `.matchedGeometryEffect` transitions between grid items and full-screen detail views.
- **Empty States:** Custom illustrative empty states when no data records or search results exist.
- **Feedback Haptics:** Subtle `UIImpactFeedbackGenerator` haptic responses on user button taps and successful scans.

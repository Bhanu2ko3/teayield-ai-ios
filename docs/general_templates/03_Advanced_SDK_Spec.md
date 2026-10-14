# Component 3 Specification: Advanced iOS SDK Integration (On-Device)
**Target Weightage:** 20% (Mandatory Component)  
**Status:** Feature Blueprint  

---

## 1. On-Device Machine Learning & Vision Pipeline (Core ML + Vision)

> [!IMPORTANT]
> **Strict Policy:** Remote Cloud AI APIs (OpenAI, Gemini REST APIs) do NOT count for Component 3. All Machine Learning models must run 100% on-device.

### Pipeline Architecture:
```
+------------------+     +-----------------------+     +-------------------------+     +-------------------+
|  Camera / Image  | --> | Vision Request Handler| --> | Core ML Model Inference | --> |  SwiftUI View     |
|  Input (SwiftUI) |     |  (VNImageRequestHandler)|     | (VNCoreMLModel / Custom)|     |  Result Overlay   |
+------------------+     +-----------------------+     +-------------------------+     +-------------------+
```

### Technical Specs:
- **Frameworks Used:** `CoreML`, `Vision`, `AVFoundation`
- **Model Type:** Pre-trained Core ML model (`.mlmodel` / `.mlpackage`)
- **Use Case:** Real-time object recognition / text extraction / image classification.
- **Performance Threshold:** Inference time < 100ms on-device without blocking main UI thread.

---

## 2. Advanced Location & Geofencing (MapKit + Core Location)

> [!CAUTION]
> **No Token Usage:** Dropping a static hardcoded pin on a map receives 0 marks. Map implementation must be dynamic, data-driven, and interactive.

### Feature Mechanics:
1. **Live Data Pins:** MapKit pins generated dynamically from Core Data / Firebase database models (`[ItemRecord]`).
2. **Geofencing Alert System:**
   - Defines a `CLCircularRegion` centered on user points of interest.
   - Monitors `CLLocationManagerDelegate` methods (`didEnterRegion`, `didExitRegion`).
   - Triggers a local `UNNotification` when user enters/exits region.
3. **Wayfinding & Route Calculation:**
   - Uses `MKDirections.Request` to calculate interactive walking/driving routes from current user GPS coordinates to destination pin.

---

## 3. Advanced SDK Feature Non-Recycling Matrix

| Feature | Component 2 Scope | Component 3 Advanced Scope | Status |
| :--- | :--- | :--- | :--- |
| **Push Notifications** | Local alert triggers | N/A (Reserved for Comp 2) | Excluded |
| **Core Data** | Local SQLite storage | N/A (Reserved for Comp 2) | Excluded |
| **Face ID / Touch ID** | Biometric auth login | N/A (Reserved for Comp 2) | Excluded |
| **Core ML + Vision** | N/A | **On-Device Vision Analysis** | **ACTIVE (Comp 3)** |
| **MapKit + Geofence**| N/A | **Live Geofencing Alerts** | **ACTIVE (Comp 3)** |

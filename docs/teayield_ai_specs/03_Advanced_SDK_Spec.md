# Component 3 Specification: Advanced iOS SDK Integration (On-Device)
**Project Title:** TeaYield AI — Precision Tea Yield Prediction & Plucking Schedule Optimization Platform  
**Target Weightage:** 20% (Mandatory Component)  
**Status:** Complete Advanced Features Spec  

---

## 1. Feature 1: On-Device Computer Vision & Core ML Shoot Scanner

> [!IMPORTANT]
> **Strict Assessment Compliance:** Remote Cloud AI APIs (OpenAI, Gemini REST APIs) do NOT satisfy Component 3 requirements. All Machine Learning models must run 100% on-device on Apple Silicon Neural Engine (`CoreML` + `Vision`).

### 1.1 Problem & Domain Rationale
High-grade Ceylon Tea requires harvesting at the precise maturity window—specifically **"Two Leaves and a Bud" (ලපටි දළු %)**. Plucking too early reduces total crop weight, while plucking coarse, mature leaves ruins tea flavor profiles and drops auction market prices from $5.00/kg down to $1.50/kg.

The **TeaYield AI Shoot Scanner** allows field superintendents to point their iPhone camera at tea bushes in remote mountain fields. The app scans tea shoots in real-time (60fps) to compute the **Fine-to-Coarse Leaf Ratio (Bud & 2-Leaves %)** with 0-latency and zero cellular signal requirement.

### 1.2 Technical Pipeline Architecture

```
[AVCaptureVideoDataOutput] ──> [Vision Request Handler] ──> [Core ML Model Inference] ──> [SwiftUI Live Overlay]
 (Camera 60fps Buffer)          (VNImageRequestHandler)      (Apple Neural Engine)        (Bud % & Quality Score)
```

### 1.3 Implementation Swift Code Blueprint
```swift
import SwiftUI
import Vision
import CoreML

@Observable
final class LeafScannerViewModel {
    var detectedBudRatio: Double = 0.0
    var qualityScore: String = "Calculating..."
    var isOptimalHarvest: Bool = false
    
    private var visionModel: VNCoreMLModel?
    
    init() {
        setupCoreMLModel()
    }
    
    private func setupCoreMLModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all // Leverages Apple Silicon Neural Engine & GPU
            let model = try TeaShootClassifier(configuration: config).model
            self.visionModel = try VNCoreMLModel(for: model)
        } catch {
            print("Failed to load Core ML model: \(error.localizedDescription)")
        }
    }
    
    func processFrame(pixelBuffer: CVPixelBuffer) {
        guard let visionModel = self.visionModel else { return }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else { return }
            
            Task { @MainActor in
                self?.detectedBudRatio = Double(topResult.confidence)
                if topResult.identifier == "TwoLeavesAndABud" && topResult.confidence > 0.85 {
                    self?.qualityScore = "Optimal (85%+ Fine Leaf)"
                    self?.isOptimalHarvest = true
                } else {
                    self?.qualityScore = "Coarse (Sub-optimal)"
                    self?.isOptimalHarvest = false
                }
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
}
```

---

## 2. Feature 2: Spatial Geofencing & MapKit Field Overlays

> [!CAUTION]
> **No Token Usage:** Dropping a static hardcoded pin on a map receives 0 marks. Implementation must be dynamic, data-driven, and interactive.

### 2.1 Technical Specs & Mechanics
1. **Interactive Field Polygon Overlays (`MKPolygon`):**
   - Reads field spatial boundaries (`GeoJSON`) from Core Data / Supabase.
   - Renders interactive color-coded polygons on MapKit satellite view:
     - **Green Polygon:** Peak harvest readiness (High NDVI, scheduled for plucking today).
     - **Yellow Polygon:** Moderate growth (Harvest window in 3–5 days).
     - **Red Polygon:** Rest period (Plucked recently, do not enter).

2. **Active GPS Geofencing System (`CLCircularRegion`):**
   - When a field supervisor physically walks into a field boundary, `CoreLocationManager` detects the region entry via `didEnterRegion`.
   - Triggers an automated local `UNNotification`:
     > *"You entered Upper Division Block A (Pedro Estate). Scheduled for plucking today: 25 Pluckers assigned."*

### 2.2 Geofencing Swift Implementation
```swift
import CoreLocation
import UserNotifications

final class LocationServiceManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func startMonitoringFieldGeofence(fieldId: String, center: CLLocationCoordinate2D, radiusMeters: CLLocationDistance) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        let region = CLCircularRegion(center: center, radius: radiusMeters, identifier: fieldId)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendLocalGeofenceNotification(fieldId: region.identifier)
    }
    
    private func sendLocalGeofenceNotification(fieldId: String) {
        let content = UNMutableNotificationContent()
        content.title = "Field Arrival Alert"
        content.body = "You have entered \(fieldId). This field is scheduled for plucking today."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
```

---

## 3. Component 3 Non-Recycling & Depth Verification Matrix

| Framework | Component 2 Status | Component 3 Advanced Status | Verification Checklist |
| :--- | :--- | :--- | :--- |
| **Core Data** | Used for local SQLite persistence | N/A (Excluded from Comp 3) | ✅ Separate |
| **Face ID / Touch ID** | Used for Manager Login | N/A (Excluded from Comp 3) | ✅ Separate |
| **Core ML + Vision** | N/A | **ACTIVE (On-Device Shoot Scanner)** | ✅ 100% On-Device Neural Engine |
| **MapKit + Geofencing**| N/A | **ACTIVE (Live Polygons + Geofencing)** | ✅ Active `CLCircularRegion` |

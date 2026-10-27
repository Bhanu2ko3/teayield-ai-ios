import SwiftUI
import MapKit

/// UIViewRepresentable wrapping Apple MapKit MKMapView with custom vector polygon rendering and annotation callouts.
struct InteractiveMapView: UIViewRepresentable {

    let fields: [TeaField]
    let selectedField: TeaField?
    let mapType: MKMapType
    let cameraRegion: MKCoordinateRegion
    let onSelectField: (TeaField) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.setRegion(cameraRegion, animated: false)

        // Add tap gesture to detect polygon overlay taps
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)

        updateOverlays(in: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapView.mapType != mapType {
            mapView.mapType = mapType
        }

        // Check if overlays need synchronization
        let existingPolygons = mapView.overlays.compactMap { $0 as? TeaFieldPolygon }
        let currentFieldIds = Set(fields.map { $0.id })
        let existingFieldIds = Set(existingPolygons.compactMap { $0.field?.id })

        if currentFieldIds != existingFieldIds {
            updateOverlays(in: mapView)
        }

        // Animate region updates
        let centerDiff = abs(mapView.region.center.latitude - cameraRegion.center.latitude) +
                         abs(mapView.region.center.longitude - cameraRegion.center.longitude)
        if centerDiff > 0.0005 {
            mapView.setRegion(cameraRegion, animated: true)
        }
    }

    private func updateOverlays(in mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        for field in fields {
            guard !field.polygonCoordinates.isEmpty else { continue }

            var coords = field.polygonCoordinates.map { $0.clCoordinate }
            let polygon = TeaFieldPolygon(coordinates: &coords, count: coords.count)
            polygon.field = field
            mapView.addOverlay(polygon)

            let annotation = TeaFieldAnnotation(field: field)
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: InteractiveMapView

        init(_ parent: InteractiveMapView) {
            self.parent = parent
        }

        // MARK: - Overlay Renderer (NDVI Color Coding)

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let fieldPolygon = overlay as? TeaFieldPolygon,
                  let field = fieldPolygon.field else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolygonRenderer(polygon: fieldPolygon)
            let fillColor: UIColor
            let strokeColor: UIColor

            switch field.status {
            case .ready:
                // High NDVI healthy canopy (Emerald #059669)
                fillColor = UIColor(red: 0.02, green: 0.59, blue: 0.41, alpha: 0.45)
                strokeColor = UIColor(red: 0.02, green: 0.59, blue: 0.41, alpha: 0.95)
            case .growing:
                // Mid NDVI maturing canopy (Amber #D97706)
                fillColor = UIColor(red: 0.85, green: 0.47, blue: 0.02, alpha: 0.45)
                strokeColor = UIColor(red: 0.85, green: 0.47, blue: 0.02, alpha: 0.95)
            case .resting:
                // Low NDVI pruned canopy (Crimson #DC2626)
                fillColor = UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 0.45)
                strokeColor = UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 0.95)
            }

            renderer.fillColor = fillColor
            renderer.strokeColor = strokeColor
            renderer.lineWidth = 2.5
            return renderer
        }

        // MARK: - Annotation Views

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let fieldAnnotation = annotation as? TeaFieldAnnotation else {
                return nil
            }

            let identifier = "TeaFieldMarker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: fieldAnnotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                view?.annotation = fieldAnnotation
            }

            let field = fieldAnnotation.field
            switch field.status {
            case .ready:
                view?.markerTintColor = UIColor(red: 0.02, green: 0.59, blue: 0.41, alpha: 1.0)
            case .growing:
                view?.markerTintColor = UIColor(red: 0.85, green: 0.47, blue: 0.02, alpha: 1.0)
            case .resting:
                view?.markerTintColor = UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 1.0)
            }

            view?.glyphImage = UIImage(systemName: "leaf.fill")
            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? TeaFieldAnnotation else { return }
            parent.onSelectField(annotation.field)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? TeaFieldAnnotation else { return }
            parent.onSelectField(annotation.field)
        }

        // MARK: - Tap Gesture on Map Polygon

        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let mapPoint = MKMapPoint(coordinate)

            for overlay in mapView.overlays {
                guard let fieldPolygon = overlay as? TeaFieldPolygon,
                      let field = fieldPolygon.field else { continue }

                if let renderer = mapView.renderer(for: overlay) as? MKPolygonRenderer {
                    let pointInRenderer = renderer.point(for: mapPoint)
                    if renderer.path.contains(pointInRenderer) {
                        parent.onSelectField(field)
                        return
                    }
                }
            }
        }
    }
}

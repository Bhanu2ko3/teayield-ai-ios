import Foundation
import MapKit

/// Subclassed MKPolygon binding native vector overlay rendering to domain field telemetry.
final class TeaFieldPolygon: MKPolygon {
    var field: TeaField?
}

/// MapKit spatial point annotation marking field centroids and division names.
final class TeaFieldAnnotation: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let field: TeaField

    init(field: TeaField) {
        self.field = field
        self.coordinate = field.centroidCoordinate
        self.title = field.name
        self.subtitle = "\(field.status.displayName) • NDVI \(field.formattedNDVI)"
        super.init()
    }
}

import Foundation
import CoreLocation
import MapKit

/// Utility parser for spatial GeoJSON geometries and estate polygon coordinates.
enum GeoJSONParser {

    /// Parses a GeoJSON polygon string or raw coordinate list into CLLocationCoordinate2D array.
    static func parseCoordinates(from jsonString: String) -> [CLLocationCoordinate2D] {
        guard let data = jsonString.data(using: .utf8) else { return [] }

        // Attempt decoding as CoordinatePair array
        if let pairs = try? JSONDecoder().decode([CoordinatePair].self, from: data) {
            return pairs.map { $0.clCoordinate }
        }

        // Attempt decoding standard GeoJSON geometry: {"type": "Polygon", "coordinates": [[[lon, lat], ...]]}
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let type = json["type"] as? String, type == "Polygon",
           let rings = json["coordinates"] as? [[[Double]]],
           let outerRing = rings.first {
            return outerRing.compactMap { point in
                guard point.count >= 2 else { return nil }
                // GeoJSON standard: [longitude, latitude]
                return CLLocationCoordinate2D(latitude: point[1], longitude: point[0])
            }
        }

        return []
    }

    /// Calculates the geographical centroid coordinate of a closed polygon.
    static func calculateCentroid(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        guard !coordinates.isEmpty else {
            return CLLocationCoordinate2D(latitude: 6.9642, longitude: 80.7932) // Default Pedro Estate centroid
        }

        var totalLat: Double = 0
        var totalLon: Double = 0

        for coord in coordinates {
            totalLat += coord.latitude
            totalLon += coord.longitude
        }

        let count = Double(coordinates.count)
        return CLLocationCoordinate2D(latitude: totalLat / count, longitude: totalLon / count)
    }

    /// Creates a native MapKit MKPolygon from domain coordinate pairs.
    static func makePolygon(from coordinates: [CoordinatePair]) -> MKPolygon {
        var clCoords = coordinates.map { $0.clCoordinate }
        return MKPolygon(coordinates: &clCoords, count: clCoords.count)
    }
}

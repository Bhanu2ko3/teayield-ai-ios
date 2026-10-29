import Foundation
import CoreLocation
import MapKit
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("GeoJSON Spatial Parser Unit Tests")
struct GeoJSONParserTests {

    @Test("Verifies decoding of standard GeoJSON Polygon format")
    func parseStandardGeoJSONPolygon() {
        let geoJSON = """
        {
            "type": "Polygon",
            "coordinates": [
                [
                    [80.792, 6.966],
                    [80.794, 6.966],
                    [80.794, 6.964],
                    [80.792, 6.964]
                ]
            ]
        }
        """

        let coordinates = GeoJSONParser.parseCoordinates(from: geoJSON)

        #expect(coordinates.count == 4)
        // Verify longitude/latitude inversion: GeoJSON standard is [lon, lat]
        #expect(abs(coordinates[0].latitude - 6.966) < 0.0001)
        #expect(abs(coordinates[0].longitude - 80.792) < 0.0001)
        #expect(abs(coordinates[1].latitude - 6.966) < 0.0001)
        #expect(abs(coordinates[1].longitude - 80.794) < 0.0001)
    }

    @Test("Verifies decoding of coordinate pair JSON array")
    func parseCoordinatePairArray() {
        let jsonArray = """
        [
            {"latitude": 6.965, "longitude": 80.791},
            {"latitude": 6.967, "longitude": 80.793}
        ]
        """

        let coordinates = GeoJSONParser.parseCoordinates(from: jsonArray)

        #expect(coordinates.count == 2)
        #expect(coordinates[0].latitude == 6.965)
        #expect(coordinates[0].longitude == 80.791)
    }

    @Test("Verifies invalid JSON returns empty coordinate collection gracefully")
    func parseCorruptedJSON() {
        let corrupted = "{ invalid_json_content }"
        let coordinates = GeoJSONParser.parseCoordinates(from: corrupted)
        #expect(coordinates.isEmpty)
    }

    @Test("Verifies mathematical centroid derivation of polygon vertices")
    func calculateCentroid() {
        let vertices = [
            CLLocationCoordinate2D(latitude: 6.0, longitude: 80.0),
            CLLocationCoordinate2D(latitude: 8.0, longitude: 80.0),
            CLLocationCoordinate2D(latitude: 8.0, longitude: 82.0),
            CLLocationCoordinate2D(latitude: 6.0, longitude: 82.0)
        ]

        let centroid = GeoJSONParser.calculateCentroid(coordinates: vertices)

        #expect(abs(centroid.latitude - 7.0) < 0.0001)
        #expect(abs(centroid.longitude - 81.0) < 0.0001)
    }

    @Test("Verifies fallback default centroid on empty coordinate set")
    func calculateCentroidEmpty() {
        let centroid = GeoJSONParser.calculateCentroid(coordinates: [])

        // Expect Pedro Estate default coordinates (6.9642, 80.7932)
        #expect(abs(centroid.latitude - 6.9642) < 0.0001)
        #expect(abs(centroid.longitude - 80.7932) < 0.0001)
    }

    @Test("Verifies MKPolygon generation from coordinate pairs")
    func makePolygon() {
        let pairs = [
            CoordinatePair(latitude: 6.965, longitude: 80.791),
            CoordinatePair(latitude: 6.967, longitude: 80.791),
            CoordinatePair(latitude: 6.967, longitude: 80.793)
        ]

        let polygon = GeoJSONParser.makePolygon(from: pairs)
        #expect(polygon.pointCount == 3)
    }
}

#else
import XCTest

final class GeoJSONParserTests: XCTestCase {

    func testParseStandardGeoJSONPolygon() {
        let geoJSON = """
        {
            "type": "Polygon",
            "coordinates": [
                [
                    [80.792, 6.966],
                    [80.794, 6.966],
                    [80.794, 6.964],
                    [80.792, 6.964]
                ]
            ]
        }
        """

        let coordinates = GeoJSONParser.parseCoordinates(from: geoJSON)

        XCTAssertEqual(coordinates.count, 4)
        XCTAssertEqual(coordinates[0].latitude, 6.966, accuracy: 0.0001)
        XCTAssertEqual(coordinates[0].longitude, 80.792, accuracy: 0.0001)
        XCTAssertEqual(coordinates[1].latitude, 6.966, accuracy: 0.0001)
        XCTAssertEqual(coordinates[1].longitude, 80.794, accuracy: 0.0001)
    }

    func testParseCoordinatePairArray() {
        let jsonArray = """
        [
            {"latitude": 6.965, "longitude": 80.791},
            {"latitude": 6.967, "longitude": 80.793}
        ]
        """

        let coordinates = GeoJSONParser.parseCoordinates(from: jsonArray)

        XCTAssertEqual(coordinates.count, 2)
        XCTAssertEqual(coordinates[0].latitude, 6.965)
        XCTAssertEqual(coordinates[0].longitude, 80.791)
    }

    func testParseCorruptedJSON() {
        let corrupted = "{ invalid_json_content }"
        let coordinates = GeoJSONParser.parseCoordinates(from: corrupted)
        XCTAssertTrue(coordinates.isEmpty)
    }

    func testCalculateCentroid() {
        let vertices = [
            CLLocationCoordinate2D(latitude: 6.0, longitude: 80.0),
            CLLocationCoordinate2D(latitude: 8.0, longitude: 80.0),
            CLLocationCoordinate2D(latitude: 8.0, longitude: 82.0),
            CLLocationCoordinate2D(latitude: 6.0, longitude: 82.0)
        ]

        let centroid = GeoJSONParser.calculateCentroid(coordinates: vertices)

        XCTAssertEqual(centroid.latitude, 7.0, accuracy: 0.0001)
        XCTAssertEqual(centroid.longitude, 81.0, accuracy: 0.0001)
    }

    func testCalculateCentroidEmpty() {
        let centroid = GeoJSONParser.calculateCentroid(coordinates: [])

        XCTAssertEqual(centroid.latitude, 6.9642, accuracy: 0.0001)
        XCTAssertEqual(centroid.longitude, 80.7932, accuracy: 0.0001)
    }

    func testMakePolygon() {
        let pairs = [
            CoordinatePair(latitude: 6.965, longitude: 80.791),
            CoordinatePair(latitude: 6.967, longitude: 80.791),
            CoordinatePair(latitude: 6.967, longitude: 80.793)
        ]

        let polygon = GeoJSONParser.makePolygon(from: pairs)
        XCTAssertEqual(polygon.pointCount, 3)
    }
}
#endif

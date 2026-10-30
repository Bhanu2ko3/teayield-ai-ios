import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("FastAPI REST Contract & APIEndpoint Builder Unit Tests")
struct APIEndpointTests {

    @Test("Constructs correct REST endpoints and HTTP methods for Auth microservice")
    func testAuthEndpoints() {
        let loginDTO = LoginRequestDTO(email: "officer@pedro.lk", password: "SecretPassword123")
        let loginEndpoint = APIEndpoint.login(loginDTO)
        #expect(loginEndpoint.path == "auth/login")
        #expect(loginEndpoint.method == .post)

        let getMeEndpoint = APIEndpoint.getMe
        #expect(getMeEndpoint.path == "auth/me")
        #expect(getMeEndpoint.method == .get)

        let pwDTO = PasswordChangeRequestDTO(currentPassword: "OldPassword1!", newPassword: "NewPassword2!")
        let pwEndpoint = APIEndpoint.changePassword(pwDTO)
        #expect(pwEndpoint.path == "auth/change-password")
        #expect(pwEndpoint.method == .post)
    }

    @Test("Constructs correct REST endpoints for Spatial Division & NDVI services")
    func testFieldAndNDVIEndpoints() {
        let estateId = UUID()
        let fieldsEndpoint = APIEndpoint.getFields(estateId: estateId)
        #expect(fieldsEndpoint.path == "estates/\(estateId.uuidString.lowercased())/fields")
        #expect(fieldsEndpoint.method == .get)

        let fieldId = UUID()
        let ndviEndpoint = APIEndpoint.getFieldNDVI(fieldId: fieldId, limit: 10)
        #expect(ndviEndpoint.path == "fields/\(fieldId.uuidString.lowercased())/ndvi")
        #expect(ndviEndpoint.method == .get)
        #expect(ndviEndpoint.queryItems?.contains(where: { $0.name == "limit" && $0.value == "10" }) == true)
    }

    @Test("Constructs correct REST endpoints for AI Yield Prediction & Genetic Algorithm Roster")
    func testAIModelEndpoints() {
        let triggerDTO = PredictionTriggerDTO(
            estateId: UUID(),
            targetDate: "2026-11-01",
            includeNDVI: true,
            includeWeather: true
        )
        let predictEndpoint = APIEndpoint.triggerYieldPrediction(triggerDTO)
        #expect(predictEndpoint.path == "yield/predict")
        #expect(predictEndpoint.method == .post)

        let rosterDTO = RosterOptimizationRequestDTO(
            estateId: UUID(),
            weekStartDate: "2026-11-02",
            availableWorkers: 30,
            maxConsecutiveDays: 6,
            minDailyHarvestersPerField: 4
        )
        let rosterEndpoint = APIEndpoint.optimizeRoster(rosterDTO)
        #expect(rosterEndpoint.path == "roster/optimize")
        #expect(rosterEndpoint.method == .post)
    }

    @Test("Builds full valid RFC-compliant URLSession URLRequests")
    func testFullURLRequestGeneration() throws {
        let endpoint = APIEndpoint.getMe
        let token = "sample_test_jwt_bearer_token"
        let request = try endpoint.urlRequest(baseURL: AppConfiguration.apiBaseURL, token: token)

        #expect(request.url != nil)
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(token)")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }
}

#else
import XCTest

final class APIEndpointTests: XCTestCase {
    func testAuthEndpoints() {
        let loginDTO = LoginRequestDTO(email: "officer@pedro.lk", password: "SecretPassword123")
        let loginEndpoint = APIEndpoint.login(loginDTO)
        XCTAssertEqual(loginEndpoint.path, "auth/login")
        XCTAssertEqual(loginEndpoint.method, .post)
    }
}
#endif

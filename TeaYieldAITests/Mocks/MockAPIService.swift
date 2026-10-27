import Foundation
@testable import TeaYieldAI

/// Test double implementing APIServiceProtocol for unit testing networking operations.
final class MockAPIService: APIServiceProtocol {

    var authToken: String? = nil
    var mockLoginResponse: TokenResponseDTO?
    var mockUserProfile: UserProfileDTO?
    var mockEstates: [EstateResponseDTO] = []
    var mockEstate: EstateResponseDTO?
    var mockFields: [FieldResponseDTO] = []
    var mockNDVILogs: [NDVILogResponseDTO] = []
    var mockWeatherLogs: [WeatherLogResponseDTO] = []
    var mockDailyTasksResponse: DailySupervisorTasksResponseDTO?
    var mockSyncResponse: HarvestSyncResponseDTO?
    var mockHarvestLogs: [HarvestLogRecordResponseDTO] = []

    var shouldFailRequests: Bool = false
    var simulatedNetworkError: Error?

    private(set) var recordedSyncBatches: [HarvestSyncBatchDTO] = []
    private(set) var recordedLoginCredentials: LoginRequestDTO?

    func login(credentials: LoginRequestDTO) async throws -> TokenResponseDTO {
        recordedLoginCredentials = credentials
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.unauthorized
        }
        if let response = mockLoginResponse {
            return response
        }
        return TokenResponseDTO(
            accessToken: "mock_jwt_token",
            tokenType: "bearer",
            expiresIn: 3600
        )
    }

    func fetchCurrentUserProfile() async throws -> UserProfileDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.unauthorized
        }
        if let profile = mockUserProfile {
            return profile
        }
        return UserProfileDTO(
            id: UUID(),
            email: "supervisor@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: "field_supervisor",
            estateId: UUID(),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func fetchEstates() async throws -> [EstateResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Mock server error")
        }
        return mockEstates
    }

    func fetchEstate(id: UUID) async throws -> EstateResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.notFound
        }
        if let estate = mockEstate {
            return estate
        }
        return EstateResponseDTO(
            id: id,
            name: "Pedro Tea Estate",
            code: "PEDRO",
            region: "Nuwara Eliya",
            country: "Sri Lanka",
            totalAcreage: 450.0,
            centroidLat: 6.9642,
            centroidLon: 80.7932,
            dailyProcessingCapacityKg: 5000.0,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func fetchFields(estateId: UUID) async throws -> [FieldResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Internal error")
        }
        return mockFields
    }

    func fetchFieldNDVI(fieldId: UUID, limit: Int?) async throws -> [NDVILogResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Internal error")
        }
        return mockNDVILogs
    }

    func fetchFieldWeather(fieldId: UUID, limit: Int?) async throws -> [WeatherLogResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Internal error")
        }
        return mockWeatherLogs
    }

    func fetchDailyTasks(estateId: UUID, dayIndex: Int?) async throws -> DailySupervisorTasksResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.connectionFailure("Simulated offline error")
        }
        if let response = mockDailyTasksResponse {
            return response
        }
        return DailySupervisorTasksResponseDTO(
            scheduleDate: "2026-10-28",
            dayIndex: dayIndex ?? 1,
            assignedFields: []
        )
    }

    func syncHarvestBatch(_ batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO {
        recordedSyncBatches.append(batch)
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Sync failure")
        }
        if let response = mockSyncResponse {
            return response
        }
        return HarvestSyncResponseDTO(
            processedRecords: batch.logs.count,
            failedRecords: 0,
            status: "success",
            syncedIds: batch.logs.map { $0.localLogId }
        )
    }

    func fetchHarvestLogs(fieldId: UUID?, limit: Int?, offset: Int?) async throws -> [HarvestLogRecordResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Fetch failure")
        }
        return mockHarvestLogs
    }
}

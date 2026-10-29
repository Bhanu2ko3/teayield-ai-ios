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

    func createField(request: FieldCreateRequestDTO) async throws -> FieldResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Internal error")
        }
        let created = FieldResponseDTO(
            id: UUID(),
            estateId: request.estateId,
            name: request.name,
            areaAcres: request.areaAcres,
            boundaryGeojson: request.boundaryGeojson,
            centroidLatitude: 6.95,
            centroidLongitude: 80.77,
            currentNdvi: 0.75,
            daysSinceLastHarvest: 7,
            harvestStatus: "READY",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        mockFields.append(created)
        return created
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

    var mockPluckers: [PluckerResponseDTO] = []
    var mockRosterResponse: RosterOptimizationResponseDTO?
    var mockPredictionBatch: YieldPredictionBatchResponseDTO?

    func signupManager(request: ManagerSignUpRequestDTO) async throws -> TokenResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Signup failure")
        }
        return TokenResponseDTO(
            accessToken: "mock_manager_jwt_token",
            tokenType: "bearer",
            expiresIn: 3600
        )
    }

    func inviteSupervisor(request: SupervisorInviteRequestDTO) async throws -> UserProfileDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Invite failure")
        }
        return UserProfileDTO(
            id: UUID(),
            email: request.email,
            fullName: request.fullName,
            role: "field_supervisor",
            estateId: UUID(),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func changePassword(request: PasswordChangeRequestDTO) async throws -> StatusResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Password change failure")
        }
        return StatusResponseDTO(status: "SUCCESS", message: "Password updated successfully")
    }

    func onboardEstate(request: EstateOnboardRequestDTO) async throws -> EstateResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Onboarding failure")
        }
        return EstateResponseDTO(
            id: UUID(),
            name: request.name,
            district: request.district ?? "Nuwara Eliya",
            elevationMeters: request.elevationMeters ?? 1868,
            totalAreaAcres: request.totalAreaAcres,
            dailyFactoryCapacityKg: request.dailyFactoryCapacityKg ?? 12000.0,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func updateEstate(id: UUID, request: EstateUpdateRequestDTO) async throws -> EstateResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Update estate failure")
        }
        return EstateResponseDTO(
            id: id,
            name: request.name ?? "Updated Estate",
            district: request.district ?? "Nuwara Eliya",
            elevationMeters: request.elevationMeters ?? 1868,
            totalAreaAcres: request.totalAreaAcres ?? 150.0,
            dailyFactoryCapacityKg: request.dailyFactoryCapacityKg ?? 12000.0,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func createField(request: FieldCreateRequestDTO) async throws -> FieldResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Field creation failure")
        }
        return FieldResponseDTO(
            id: UUID(),
            estateId: request.estateId,
            name: request.name,
            areaAcres: request.areaAcres,
            boundaryGeojson: request.boundaryGeojson,
            centroidLatitude: 6.9642,
            centroidLongitude: 80.7932,
            currentNdvi: 0.78,
            daysSinceLastHarvest: 0,
            harvestStatus: "READY",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func fetchPluckers(estateId: UUID) async throws -> [PluckerResponseDTO] {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Pluckers fetch failure")
        }
        return mockPluckers
    }

    func createPlucker(request: PluckerCreateRequestDTO) async throws -> PluckerResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Plucker creation failure")
        }
        return PluckerResponseDTO(
            id: UUID(),
            estateId: request.estateId,
            pluckerCode: request.pluckerCode,
            fullName: request.fullName,
            averageDailyRateKg: request.averageDailyRateKg ?? 25.0,
            isActive: request.isActive ?? true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func triggerYieldPrediction(request: PredictionTriggerDTO) async throws -> YieldPredictionBatchResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Prediction trigger failure")
        }
        if let batch = mockPredictionBatch {
            return batch
        }
        return YieldPredictionBatchResponseDTO(
            predictionBatchId: "BATCH-MOCK-001",
            targetWeekStart: request.targetWeekStart,
            totalPredictedYieldKg: 14250.0,
            predictions: []
        )
    }

    func optimizeRoster(request: RosterOptimizationRequestDTO) async throws -> RosterOptimizationResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Roster optimization failure")
        }
        if let roster = mockRosterResponse {
            return roster
        }
        return RosterOptimizationResponseDTO(
            rosterId: "ROSTER-MOCK-001",
            estateId: request.estateId,
            weekStartDate: request.weekStartDate,
            totalPlannedYieldKg: 18500.0,
            workforceUtilizationPct: 94.5,
            days: []
        )
    }

    func fetchCurrentRoster(estateId: UUID, weekStartDate: String) async throws -> RosterOptimizationResponseDTO {
        if shouldFailRequests {
            throw simulatedNetworkError ?? NetworkError.serverError(500, "Roster fetch failure")
        }
        if let roster = mockRosterResponse {
            return roster
        }
        return RosterOptimizationResponseDTO(
            rosterId: "ROSTER-MOCK-001",
            estateId: estateId,
            weekStartDate: weekStartDate,
            totalPlannedYieldKg: 18500.0,
            workforceUtilizationPct: 94.5,
            days: []
        )
    }
}

import Foundation

/// Primary production networking service using async/await and URLSession to interact with the backend API.
final class CloudAPIService: APIServiceProtocol {

    var authToken: String?
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL
        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = AppConfiguration.timeoutInterval
            config.timeoutIntervalForResource = AppConfiguration.timeoutInterval
            config.waitsForConnectivity = false
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            self.session = URLSession(configuration: config)
        }
        self.decoder = JSONDecoder()
    }

    // MARK: - APIServiceProtocol Methods

    func login(credentials: LoginRequestDTO) async throws -> TokenResponseDTO {
        let tokenResponse: TokenResponseDTO = try await execute(.login(credentials))
        self.authToken = tokenResponse.accessToken
        return tokenResponse
    }

    func fetchCurrentUserProfile() async throws -> UserProfileDTO {
        try await execute(.getMe)
    }

    func fetchEstates() async throws -> [EstateResponseDTO] {
        try await execute(.listEstates)
    }

    func fetchEstate(id: UUID) async throws -> EstateResponseDTO {
        try await execute(.getEstate(id: id))
    }

    func fetchFields(estateId: UUID) async throws -> [FieldResponseDTO] {
        try await execute(.getFields(estateId: estateId))
    }

    func createField(request: FieldCreateRequestDTO) async throws -> FieldResponseDTO {
        try await execute(.createField(request))
    }

    func fetchFieldNDVI(fieldId: UUID, limit: Int? = 12) async throws -> [NDVILogResponseDTO] {
        try await execute(.getFieldNDVI(fieldId: fieldId, limit: limit))
    }

    func fetchFieldWeather(fieldId: UUID, limit: Int? = 12) async throws -> [WeatherLogResponseDTO] {
        try await execute(.getFieldWeather(fieldId: fieldId, limit: limit))
    }

    func fetchDailyTasks(estateId: UUID, dayIndex: Int? = nil) async throws -> DailySupervisorTasksResponseDTO {
        try await execute(.getDailyTasks(estateId: estateId, dayIndex: dayIndex))
    }

    func syncHarvestBatch(_ batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO {
        try await execute(.syncHarvest(batch))
    }

    func fetchHarvestLogs(fieldId: UUID? = nil, limit: Int? = 50, offset: Int? = 0) async throws -> [HarvestLogRecordResponseDTO] {
        try await execute(.getHarvestLogs(fieldId: fieldId, limit: limit, offset: offset))
    }

    func signupManager(request: ManagerSignUpRequestDTO) async throws -> TokenResponseDTO {
        let tokenResponse: TokenResponseDTO = try await execute(.signupManager(request))
        self.authToken = tokenResponse.accessToken
        return tokenResponse
    }

    func inviteSupervisor(request: SupervisorInviteRequestDTO) async throws -> UserProfileDTO {
        try await execute(.inviteSupervisor(request))
    }

    func changePassword(request: PasswordChangeRequestDTO) async throws -> StatusResponseDTO {
        try await execute(.changePassword(request))
    }

    func onboardEstate(request: EstateOnboardRequestDTO) async throws -> EstateResponseDTO {
        try await execute(.onboardEstate(request))
    }

    func updateEstate(id: UUID, request: EstateUpdateRequestDTO) async throws -> EstateResponseDTO {
        try await execute(.updateEstate(id: id, payload: request))
    }

    func createField(request: FieldCreateRequestDTO) async throws -> FieldResponseDTO {
        try await execute(.createField(request))
    }

    func fetchPluckers(estateId: UUID) async throws -> [PluckerResponseDTO] {
        try await execute(.listPluckers(estateId: estateId))
    }

    func createPlucker(request: PluckerCreateRequestDTO) async throws -> PluckerResponseDTO {
        try await execute(.createPlucker(request))
    }

    func triggerYieldPrediction(request: PredictionTriggerDTO) async throws -> YieldPredictionBatchResponseDTO {
        try await execute(.triggerYieldPrediction(request))
    }

    func optimizeRoster(request: RosterOptimizationRequestDTO) async throws -> RosterOptimizationResponseDTO {
        try await execute(.optimizeRoster(request))
    }

    func fetchCurrentRoster(estateId: UUID, weekStartDate: String) async throws -> RosterOptimizationResponseDTO {
        try await execute(.getCurrentRoster(estateId: estateId, weekStartDate: weekStartDate))
    }

    // MARK: - Private Request Executor

    private func execute<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var request = try endpoint.asURLRequest(baseURL: baseURL, authToken: authToken)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError {
            if urlError.code == .cancelled {
                throw CancellationError()
            }
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw NetworkError.connectionFailure("No internet connection")
            }
            throw NetworkError.connectionFailure(urlError.localizedDescription)
        } catch {
            throw NetworkError.connectionFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error.localizedDescription)
            }

        case 401:
            self.authToken = nil
            throw NetworkError.unauthorized

        case 403:
            throw NetworkError.forbidden

        case 404:
            if let errorDTO = try? decoder.decode(APIErrorResponseDTO.self, from: data) {
                throw NetworkError.notFound(errorDTO.errorDescription ?? errorDTO.message)
            }
            throw NetworkError.notFound("Requested resource was not found.")

        default:
            if let errorDTO = try? decoder.decode(APIErrorResponseDTO.self, from: data) {
                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode,
                    message: errorDTO.errorDescription ?? errorDTO.message,
                    errorCode: errorDTO.errorCode
                )
            }
            let rawMessage = String(data: data, encoding: .utf8) ?? "Server returned error \(httpResponse.statusCode)"
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: rawMessage,
                errorCode: "HTTP_\(httpResponse.statusCode)"
            )
        }
    }
}

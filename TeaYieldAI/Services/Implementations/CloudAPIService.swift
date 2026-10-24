import Foundation

/// Primary production networking service using async/await and URLSession to interact with the backend API.
final class CloudAPIService: APIServiceProtocol {

    var authToken: String?
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = AppConfiguration.apiBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
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

    // MARK: - Private Request Executor

    private func execute<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var request = try endpoint.asURLRequest(baseURL: baseURL, authToken: authToken)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        var data: Data
        var response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError {
            if urlError.code == .cancelled {
                throw CancellationError()
            }
            // Auto-detect QEMU host loopback alias 10.0.2.2 if 127.0.0.1 is not reachable
            if baseURL.host == "127.0.0.1",
               let altURL = URL(string: baseURL.absoluteString.replacingOccurrences(of: "127.0.0.1", with: "10.0.2.2")),
               let altRequest = try? endpoint.asURLRequest(baseURL: altURL, authToken: authToken) {
                do {
                    (data, response) = try await session.data(for: altRequest)
                } catch {
                    if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                        throw NetworkError.connectionFailure("No internet connection")
                    }
                    throw NetworkError.connectionFailure("Estate cloud backend unreachable. Please verify the FastAPI server is running.")
                }
            } else {
                if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                    throw NetworkError.connectionFailure("No internet connection")
                }
                throw NetworkError.connectionFailure(urlError.localizedDescription)
            }
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

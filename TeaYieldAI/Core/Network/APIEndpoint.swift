import Foundation

/// HTTP method verbs supported by the API client.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Type-safe endpoint builder for FastAPI backend microservices.
enum APIEndpoint {
    case login(LoginRequestDTO)
    case signupManager(ManagerSignUpRequestDTO)
    case inviteSupervisor(SupervisorInviteRequestDTO)
    case changePassword(PasswordChangeRequestDTO)
    case getMe
    case listEstates
    case onboardEstate(EstateOnboardRequestDTO)
    case getEstate(id: UUID)
    case getFields(estateId: UUID)
    case createField(FieldCreateRequestDTO)
    case getFieldNDVI(fieldId: UUID, limit: Int?)
    case getFieldWeather(fieldId: UUID, limit: Int?)
    case listPluckers(estateId: UUID)
    case createPlucker(PluckerCreateRequestDTO)
    case getDailyTasks(estateId: UUID, dayIndex: Int?)
    case triggerYieldPrediction(PredictionTriggerDTO)
    case optimizeRoster(RosterOptimizationRequestDTO)
    case getCurrentRoster(estateId: UUID, weekStartDate: String)
    case syncHarvest(HarvestSyncBatchDTO)
    case getHarvestLogs(fieldId: UUID?, limit: Int?, offset: Int?)

    var path: String {
        switch self {
        case .login:
            return "auth/login"
        case .signupManager:
            return "auth/signup-manager"
        case .inviteSupervisor:
            return "auth/invite-supervisor"
        case .changePassword:
            return "auth/change-password"
        case .getMe:
            return "auth/me"
        case .listEstates:
            return "estates"
        case .onboardEstate:
            return "estates/onboard"
        case .getEstate(let id):
            return "estates/\(id.uuidString)"
        case .getFields, .createField:
            return "fields"
        case .getFieldNDVI(let fieldId, _):
            return "fields/\(fieldId.uuidString)/ndvi"
        case .getFieldWeather(let fieldId, _):
            return "fields/\(fieldId.uuidString)/weather"
        case .listPluckers, .createPlucker:
            return "pluckers"
        case .getDailyTasks:
            return "tasks/daily"
        case .triggerYieldPrediction:
            return "yield/predict"
        case .optimizeRoster:
            return "roster/optimize"
        case .getCurrentRoster:
            return "roster/current"
        case .syncHarvest:
            return "harvest/sync"
        case .getHarvestLogs:
            return "harvest/logs"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .signupManager, .inviteSupervisor, .changePassword, .onboardEstate, .createPlucker, .createField, .triggerYieldPrediction, .optimizeRoster, .syncHarvest:
            return .post
        case .getMe, .listEstates, .getEstate, .getFields, .getFieldNDVI, .getFieldWeather, .listPluckers, .getDailyTasks, .getCurrentRoster, .getHarvestLogs:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getFields(let estateId):
            return [URLQueryItem(name: "estate_id", value: estateId.uuidString)]
        case .getFieldNDVI(_, let limit):
            guard let limit = limit else { return nil }
            return [URLQueryItem(name: "limit", value: String(limit))]
        case .getFieldWeather(_, let limit):
            guard let limit = limit else { return nil }
            return [URLQueryItem(name: "limit", value: String(limit))]
        case .listPluckers(let estateId):
            return [URLQueryItem(name: "estate_id", value: estateId.uuidString)]
        case .getDailyTasks(let estateId, let dayIndex):
            var items = [URLQueryItem(name: "estate_id", value: estateId.uuidString)]
            if let dayIndex = dayIndex {
                items.append(URLQueryItem(name: "day_index", value: String(dayIndex)))
            }
            return items
        case .getCurrentRoster(let estateId, let weekStartDate):
            return [
                URLQueryItem(name: "estate_id", value: estateId.uuidString),
                URLQueryItem(name: "week_start_date", value: weekStartDate)
            ]
        case .getHarvestLogs(let fieldId, let limit, let offset):
            var items: [URLQueryItem] = []
            if let fieldId = fieldId {
                items.append(URLQueryItem(name: "field_id", value: fieldId.uuidString))
            }
            if let limit = limit {
                items.append(URLQueryItem(name: "limit", value: String(limit)))
            }
            if let offset = offset {
                items.append(URLQueryItem(name: "offset", value: String(offset)))
            }
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .login(let payload):
            return try? encoder.encode(payload)
        case .signupManager(let payload):
            return try? encoder.encode(payload)
        case .inviteSupervisor(let payload):
            return try? encoder.encode(payload)
        case .changePassword(let payload):
            return try? encoder.encode(payload)
        case .onboardEstate(let payload):
            return try? encoder.encode(payload)
        case .createPlucker(let payload):
            return try? encoder.encode(payload)
        case .createField(let payload):
            return try? encoder.encode(payload)
        case .triggerYieldPrediction(let payload):
            return try? encoder.encode(payload)
        case .optimizeRoster(let payload):
            return try? encoder.encode(payload)
        case .syncHarvest(let batch):
            return try? encoder.encode(batch)
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .signupManager:
            return false
        default:
            return true
        }
    }

    /// Constructs a fully configured URLRequest targeting the given base URL without percent-encoding path separators.
    func asURLRequest(baseURL: URL, authToken: String?) throws -> URLRequest {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let fullURLString = baseURL.absoluteString.hasSuffix("/")
            ? "\(baseURL.absoluteString)\(cleanPath)"
            : "\(baseURL.absoluteString)/\(cleanPath)"

        guard var components = URLComponents(string: fullURLString) else {
            throw NetworkError.invalidURL
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.timeoutInterval = AppConfiguration.timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }
}

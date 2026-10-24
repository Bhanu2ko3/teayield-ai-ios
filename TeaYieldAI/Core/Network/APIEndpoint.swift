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
    case getEstate(id: UUID)
    case getFields(estateId: UUID)
    case getDailyTasks(estateId: UUID, dayIndex: Int?)
    case syncHarvest(HarvestSyncBatchDTO)

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .getEstate(let id):
            return "/estates/\(id.uuidString)"
        case .getFields:
            return "/fields"
        case .getDailyTasks:
            return "/tasks/daily"
        case .syncHarvest:
            return "/harvest/sync"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .syncHarvest:
            return .post
        case .getEstate, .getFields, .getDailyTasks:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getFields(let estateId):
            return [URLQueryItem(name: "estate_id", value: estateId.uuidString)]
        case .getDailyTasks(let estateId, let dayIndex):
            var items = [URLQueryItem(name: "estate_id", value: estateId.uuidString)]
            if let dayIndex = dayIndex {
                items.append(URLQueryItem(name: "day_index", value: String(dayIndex)))
            }
            return items
        default:
            return nil
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .login(let payload):
            return try? encoder.encode(payload)
        case .syncHarvest(let batch):
            return try? encoder.encode(batch)
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login:
            return false
        default:
            return true
        }
    }

    /// Constructs a fully configured URLRequest targeting the given base URL.
    func asURLRequest(baseURL: URL, authToken: String?) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
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

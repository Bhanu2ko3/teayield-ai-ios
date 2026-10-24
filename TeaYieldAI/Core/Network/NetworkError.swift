import Foundation

/// Specific network errors encountered during REST API communication.
enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound(String)
    case serverError(statusCode: Int, message: String, errorCode: String)
    case decodingError(String)
    case connectionFailure(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unauthorized:
            return "Session expired or invalid credentials. Please log in again."
        case .forbidden:
            return "You do not have permission to perform this action."
        case .notFound(let message):
            return message
        case .serverError(_, let message, _):
            return message
        case .decodingError(let details):
            return "Failed to parse data from the server: \(details)"
        case .connectionFailure(let message):
            return "Unable to connect to the server. Check your network: \(message)"
        case .unknown:
            return "An unexpected network error occurred."
        }
    }
}

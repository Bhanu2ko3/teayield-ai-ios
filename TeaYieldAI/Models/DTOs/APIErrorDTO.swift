import Foundation

/// Standard RFC 7807 problem details error payload returned by FastAPI.
struct APIErrorResponseDTO: Codable, LocalizedError {
    let statusCode: Int
    let errorCode: String
    let message: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case errorCode = "error_code"
        case message
        case timestamp
    }
    
    var errorDescription: String? {
        message
    }
}

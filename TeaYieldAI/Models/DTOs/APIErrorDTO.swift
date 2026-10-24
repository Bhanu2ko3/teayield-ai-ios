import Foundation

/// Detailed field validation failure item returned by FastAPI on 422 errors.
struct ValidationErrorItemDTO: Codable {
    let loc: [String]?
    let msg: String?
    let type: String?
}

/// Standard RFC 7807 problem details error payload returned by FastAPI.
struct APIErrorResponseDTO: Codable, LocalizedError {
    let statusCode: Int
    let errorCode: String
    let message: String
    let timestamp: String
    let details: [ValidationErrorItemDTO]?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case errorCode = "error_code"
        case message
        case timestamp
        case details
    }
    
    var errorDescription: String? {
        if let details = details, !details.isEmpty {
            let fieldMessages = details.compactMap { item -> String? in
                guard let msg = item.msg else { return nil }
                if let field = item.loc?.last {
                    return "\(field): \(msg)"
                }
                return msg
            }.joined(separator: "; ")
            
            if !fieldMessages.isEmpty {
                return "\(message) (\(fieldMessages))"
            }
        }
        return message
    }
}

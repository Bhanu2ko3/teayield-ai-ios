import Foundation

/// Application runtime configuration for API networking and service endpoints.
enum AppConfiguration {

    /// Base URL for the backend FastAPI REST services.
    /// Can be overridden via the API_BASE_URL environment variable in the Xcode Scheme.
    static var apiBaseURL: URL {
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"],
           let url = URL(string: envURL) {
            return url
        }
        
        #if DEBUG
        return URL(string: "http://127.0.0.1:8000/api/v1")!
        #else
        return URL(string: "https://api.teayield.ai/api/v1")!
        #endif
    }

    /// Timeout interval in seconds for network requests.
    static let timeoutInterval: TimeInterval = 15.0

    /// Minimum fine leaf ratio required for premium export tea classification (SLTB Benchmark).
    static let fineLeafTargetRatio: Double = 0.85

    /// Runtime deployment environment label.
    static var environmentName: String {
        #if DEBUG
        return "Development Edge"
        #else
        return "Production Edge"
        #endif
    }
}

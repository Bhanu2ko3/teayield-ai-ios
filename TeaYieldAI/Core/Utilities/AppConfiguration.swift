import Foundation

/// Application runtime configuration for API networking and service endpoints.
enum AppConfiguration {

    /// Official live production endpoint hosted on Oracle Cloud Infrastructure and routed via Cloudflare Edge SSL.
    static let productionBaseURL = URL(string: "https://teayield-api.codebroai.com/api/v1")!

    /// Local development endpoint for direct loopback debugging against an active local backend instance.
    static let localDevelopmentBaseURL = URL(string: "http://127.0.0.1:8000/api/v1")!

    /// Base URL for the backend FastAPI REST services.
    /// Priority resolution:
    /// 1. `API_BASE_URL` environment variable (for custom testing and CI pipelines).
    /// 2. `USE_LOCAL_BACKEND` environment variable set to "1" or "true" (for local testing).
    /// 3. Defaults to `productionBaseURL` for both Simulator and physical iPhone/iPad hardware.
    static var apiBaseURL: URL {
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"],
           let url = URL(string: envURL) {
            return url
        }

        if let useLocal = ProcessInfo.processInfo.environment["USE_LOCAL_BACKEND"],
           useLocal == "1" || useLocal.lowercased() == "true" {
            return localDevelopmentBaseURL
        }

        return productionBaseURL
    }

    /// Timeout interval in seconds for network requests.
    static let timeoutInterval: TimeInterval = 15.0

    /// Minimum fine leaf ratio required for premium export tea classification (SLTB Benchmark).
    static let fineLeafTargetRatio: Double = 0.85

    /// Standard Sri Lanka Tea Research Institute (TRI) green leaf harvest benchmark:
    /// Approximately 195 kg green leaf per acre per plucking round in high-grown tea estates.
    static let benchmarkYieldPerAcreKg: Double = 195.0

    /// Runtime deployment environment label.
    static var environmentName: String {
        if apiBaseURL == localDevelopmentBaseURL {
            return "Local Edge Network"
        }
        return "Production Cloud API"
    }
}

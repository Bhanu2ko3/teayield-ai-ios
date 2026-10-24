import Foundation

/// Defines the contract for caching and querying historical satellite NDVI vegetation logs.
protocol NDVIRepositoryProtocol {
    /// Retrieves historical NDVI observations for a specific tea field block.
    func fetchNDVIHistory(for fieldId: UUID) async throws -> [NDVILogResponseDTO]

    /// Saves or updates a batch of Sentinel-2 NDVI multispectral observations.
    func saveNDVILogs(_ logs: [NDVILogResponseDTO]) async throws
}

import Foundation

/// Defines the contract for all network communication with the TeaYield backend API.
protocol APIServiceProtocol: AnyObject {
    /// Active bearer authorization token for authenticated requests.
    var authToken: String? { get set }

    /// Authenticates user credentials and returns a bearer token session.
    func login(credentials: LoginRequestDTO) async throws -> TokenResponseDTO

    /// Fetches tea estate details including processing capacity and acreage.
    func fetchEstate(id: UUID) async throws -> EstateResponseDTO

    /// Fetches all registered tea field plots with spatial polygon coordinates for an estate.
    func fetchFields(estateId: UUID) async throws -> [FieldResponseDTO]

    /// Fetches the daily plucking briefing and assigned fields for a field supervisor.
    func fetchDailyTasks(estateId: UUID, dayIndex: Int?) async throws -> DailySupervisorTasksResponseDTO

    /// Synchronizes a batch of offline harvest weigh-in records.
    func syncHarvestBatch(_ batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO
}

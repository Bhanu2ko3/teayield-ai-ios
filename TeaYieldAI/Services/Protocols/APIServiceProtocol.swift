import Foundation

/// Defines the contract for all network communication with the TeaYield backend API.
protocol APIServiceProtocol: AnyObject {
    /// Active bearer authorization token for authenticated requests.
    var authToken: String? { get set }

    /// Authenticates user credentials and returns a bearer token session.
    func login(credentials: LoginRequestDTO) async throws -> TokenResponseDTO

    /// Fetches the profile of the currently authenticated user.
    func fetchCurrentUserProfile() async throws -> UserProfileDTO

    /// Fetches all registered commercial tea plantations.
    func fetchEstates() async throws -> [EstateResponseDTO]

    /// Fetches tea estate details including processing capacity and acreage.
    func fetchEstate(id: UUID) async throws -> EstateResponseDTO

    /// Fetches all registered tea field plots with spatial polygon coordinates for an estate.
    func fetchFields(estateId: UUID) async throws -> [FieldResponseDTO]

    /// Registers a new spatial tea field polygon in the cloud database.
    func createField(request: FieldCreateRequestDTO) async throws -> FieldResponseDTO

    /// Fetches historical Sentinel-2 NDVI multispectral satellite observations for a field.
    func fetchFieldNDVI(fieldId: UUID, limit: Int?) async throws -> [NDVILogResponseDTO]

    /// Fetches historical meteorological reanalysis time-series records for a field.
    func fetchFieldWeather(fieldId: UUID, limit: Int?) async throws -> [WeatherLogResponseDTO]

    /// Fetches the daily plucking briefing and assigned fields for a field supervisor.
    func fetchDailyTasks(estateId: UUID, dayIndex: Int?) async throws -> DailySupervisorTasksResponseDTO

    /// Synchronizes a batch of offline harvest weigh-in records.
    func syncHarvestBatch(_ batch: HarvestSyncBatchDTO) async throws -> HarvestSyncResponseDTO

    /// Fetches historical persisted green leaf intake records.
    func fetchHarvestLogs(fieldId: UUID?, limit: Int?, offset: Int?) async throws -> [HarvestLogRecordResponseDTO]

    /// Registers a new estate manager via self-service onboarding.
    func signupManager(request: ManagerSignUpRequestDTO) async throws -> TokenResponseDTO

    /// Provisions a subordinate field supervisor under the authenticated manager.
    func inviteSupervisor(request: SupervisorInviteRequestDTO) async throws -> UserProfileDTO

    /// Rotates account credentials.
    func changePassword(request: PasswordChangeRequestDTO) async throws -> StatusResponseDTO

    /// Onboards a new tea estate with physical parameters and factory ceilings.
    func onboardEstate(request: EstateOnboardRequestDTO) async throws -> EstateResponseDTO

    /// Fetches the master registered plucker workforce for an estate.
    func fetchPluckers(estateId: UUID) async throws -> [PluckerResponseDTO]

    /// Registers a new tea plucker employee.
    func createPlucker(request: PluckerCreateRequestDTO) async throws -> PluckerResponseDTO

    /// Triggers on-demand multivariate LSTM deep learning yield forecast execution.
    func triggerYieldPrediction(request: PredictionTriggerDTO) async throws -> YieldPredictionBatchResponseDTO

    /// Executes DEAP Genetic Algorithm plucker roster schedule optimization.
    func optimizeRoster(request: RosterOptimizationRequestDTO) async throws -> RosterOptimizationResponseDTO

    /// Retrieves the active weekly plucking schedule.
    func fetchCurrentRoster(estateId: UUID, weekStartDate: String) async throws -> RosterOptimizationResponseDTO
}

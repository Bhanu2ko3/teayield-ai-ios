import Foundation
import CoreData

/// Defines the protocol interface for application dependency injection.
@MainActor
protocol AppContainerProtocol {
    var apiService: APIServiceProtocol { get }
    var authService: AuthServiceProtocol { get }
    var fieldRepository: FieldRepositoryProtocol { get }
    var harvestRepository: HarvestRepositoryProtocol { get }
    var ndviRepository: NDVIRepositoryProtocol { get }
    var syncManager: SyncManagerProtocol { get }
    var persistenceController: PersistenceController { get }
    var cameraService: CameraServiceProtocol { get }
    var leafClassifier: VisionLeafClassifierProtocol { get }
}

/// Central dependency injection container providing singletons and service lifecycle management.
@MainActor
final class AppContainer: AppContainerProtocol {

    static let shared = AppContainer()

    let apiService: APIServiceProtocol
    let authService: AuthServiceProtocol
    let fieldRepository: FieldRepositoryProtocol
    let harvestRepository: HarvestRepositoryProtocol
    let ndviRepository: NDVIRepositoryProtocol
    let syncManager: SyncManagerProtocol
    let persistenceController: PersistenceController
    let cameraService: CameraServiceProtocol
    let leafClassifier: VisionLeafClassifierProtocol

    @MainActor
    private init(
        persistenceController: PersistenceController = .shared,
        apiService: APIServiceProtocol = CloudAPIService()
    ) {
        self.persistenceController = persistenceController
        self.apiService = apiService

        let auth = AuthService(apiService: apiService)
        self.authService = auth

        let fieldRepo = FieldRepository(persistenceController: persistenceController)
        let harvestRepo = HarvestRepository(persistenceController: persistenceController)
        let ndviRepo = NDVIRepository(persistenceController: persistenceController)

        self.fieldRepository = fieldRepo
        self.harvestRepository = harvestRepo
        self.ndviRepository = ndviRepo

        self.syncManager = OfflineSyncManager(
            apiService: apiService,
            harvestRepository: harvestRepo
        )

        self.cameraService = CameraService()
        self.leafClassifier = VisionLeafClassifier()
    }
}

import SwiftUI

/// Main application entry point for TeaYield AI.
@main
struct TeaYieldAIApp: App {

    @StateObject private var authService: AuthService
    private let container: AppContainerProtocol

    init() {
        #if DEBUG
        setenv("OS_ACTIVITY_MODE", "disable", 1)
        #endif
        let appContainer = AppContainer.shared
        self.container = appContainer
        self._authService = StateObject(wrappedValue: appContainer.authService as! AuthService)
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .environment(\.managedObjectContext, container.persistenceController.container.viewContext)
                .applyAppTheme()
                .task {
                    _ = await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}

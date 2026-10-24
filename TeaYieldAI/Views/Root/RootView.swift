import SwiftUI

/// Root coordinator managing active authentication state and routing between login and operational views.
struct RootView: View {

    @ObservedObject var authService: AuthService
    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        self.authService = container.authService as! AuthService
    }

    var body: some View {
        Group {
            if authService.isAuthenticated {
                TodayTasksView(container: container)
            } else {
                LoginView(viewModel: AuthViewModel(authService: container.authService))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.isAuthenticated)
    }
}

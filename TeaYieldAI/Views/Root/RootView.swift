import SwiftUI

/// Root coordinator managing onboarding status, active authentication state, and primary operational views.
struct RootView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @ObservedObject var authService: AuthService
    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        self.authService = container.authService as! AuthService
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if authService.isAuthenticated {
                SupervisorMainTabView(container: container)
            } else {
                LoginView(viewModel: AuthViewModel(authService: container.authService))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: hasCompletedOnboarding)
    }
}

import SwiftUI

/// Root coordinator managing onboarding status, active authentication state, and primary operational views.
struct RootView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @ObservedObject var authService: AuthService
    private let container: AppContainerProtocol
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(container: AppContainerProtocol) {
        self.container = container
        self.authService = container.authService as! AuthService
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else if authService.isAuthenticated {
                if horizontalSizeClass == .regular {
                    // iPad Desktop-class NavigationSplitView Executive Suite
                    ManagerExecutiveSuiteView(container: container)
                } else if authService.currentUser?.isManager == true {
                    ManagerOverviewView(container: container)
                } else {
                    SupervisorMainTabView(container: container)
                }
            } else {
                LoginView(viewModel: AuthViewModel(authService: container.authService))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: hasCompletedOnboarding)
    }
}

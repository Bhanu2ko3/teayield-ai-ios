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
            } else if !authService.isAuthenticated {
                LoginView(viewModel: AuthViewModel(authService: container.authService))
            } else if let user = authService.currentUser, user.mustChangePassword {
                // Mandatory Credential Rotation for manager-provisioned temporary passwords
                ForcePasswordChangeView(
                    authService: container.authService,
                    apiService: container.apiService
                )
            } else if let user = authService.currentUser, user.isManager && !user.hasOnboardedEstate {
                // Manager Onboarding Wizard: Ingest physical priors before operational dashboards
                EstateOnboardingView(
                    authService: container.authService,
                    apiService: container.apiService
                )
            } else if horizontalSizeClass == .regular {
                // iPad Desktop-class NavigationSplitView Executive Suite
                ManagerExecutiveSuiteView(container: container)
            } else if authService.currentUser?.isManager == true {
                // iPhone Compact Executive Overview
                ManagerOverviewView(container: container)
            } else {
                // iPhone Field Superintendent 4-Tab Workspace
                SupervisorMainTabView(container: container)
            }
        }
        .applyAppTheme()
        .animation(.easeInOut(duration: 0.25), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser?.mustChangePassword)
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser?.estateId)
        .animation(.easeInOut(duration: 0.25), value: hasCompletedOnboarding)
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: AppContainer.shared)
    }
}


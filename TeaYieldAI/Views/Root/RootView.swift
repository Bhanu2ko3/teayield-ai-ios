import SwiftUI

/// Root coordinator managing onboarding status, active authentication state, and primary operational views.
struct RootView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("requireFaceIDOnLaunch") private var requireFaceIDOnLaunch: Bool = true
    @ObservedObject var authService: AuthService
    private let container: AppContainerProtocol
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var hasUnlockedWithBiometrics: Bool = false
    @State private var isEvaluatingBiometrics: Bool = false

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
            } else if UIDevice.current.userInterfaceIdiom == .pad && authService.currentUser?.isManager == true {
                // iPad Desktop-class NavigationSplitView Executive Suite
                ManagerExecutiveSuiteView(container: container)
            } else if authService.currentUser?.isManager == true {
                // iPhone Executive 4-Tab Workspace
                ManagerMainTabView(container: container)
            } else {
                // iPhone Field Superintendent 4-Tab Workspace
                SupervisorMainTabView(container: container)
            }
        }
        .overlay {
            if authService.isAuthenticated && requireFaceIDOnLaunch && !hasUnlockedWithBiometrics && authService.isBiometricAvailable {
                BiometricLockOverlayView(
                    officerName: authService.currentUser?.fullName ?? "Officer",
                    biometryType: authService.biometricType,
                    onUnlockTap: {
                        triggerBiometricAuthentication()
                    }
                )
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .applyAppTheme()
        .animation(.easeInOut(duration: 0.25), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser?.mustChangePassword)
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser?.estateId)
        .animation(.easeInOut(duration: 0.25), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.25), value: hasUnlockedWithBiometrics)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TeaYieldLockAppRequested"))) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                hasUnlockedWithBiometrics = false
            }
        }
        .task {
            // Instant Biometric prompt on launch if authenticated and enabled
            if authService.isAuthenticated && requireFaceIDOnLaunch && !hasUnlockedWithBiometrics && authService.isBiometricAvailable {
                triggerBiometricAuthentication()
            }
        }
    }

    private func triggerBiometricAuthentication() {
        guard !isEvaluatingBiometrics else { return }
        isEvaluatingBiometrics = true
        Task {
            if let _ = try? await authService.authenticateWithBiometrics() {
                withAnimation(.easeInOut(duration: 0.25)) {
                    hasUnlockedWithBiometrics = true
                }
            }
            isEvaluatingBiometrics = false
        }
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(container: AppContainer.shared)
    }
}


import SwiftUI

/// Primary navigation shell for estate managers providing the native 4-tab bottom bar on iPhone.
/// Conforms strictly to enterprise MVVM architecture and Apple Human Interface Guidelines.
@MainActor
struct ManagerMainTabView: View {

    private let container: AppContainerProtocol
    @StateObject private var overviewViewModel: ManagerOverviewViewModel
    @State private var selectedTab: Tab = .overview

    enum Tab: Hashable {
        case overview
        case analytics
        case map
        case pluckers
        case settings
    }

    init(container: AppContainerProtocol) {
        self.container = container
        _overviewViewModel = StateObject(
            wrappedValue: ManagerOverviewViewModel(
                fieldRepository: container.fieldRepository,
                harvestRepository: container.harvestRepository,
                authService: container.authService,
                apiService: container.apiService
            )
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ManagerOverviewView(container: container, viewModel: overviewViewModel)
                .tabItem {
                    Label("Overview", systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.overview)

            NavigationStack {
                ManagerAnalyticsDashboardView(viewModel: overviewViewModel)
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(Tab.analytics)

            FieldMapView(
                viewModel: FieldMapViewModel(
                    fieldRepository: container.fieldRepository,
                    locationService: container.locationService,
                    apiService: container.apiService,
                    authService: container.authService
                )
            )
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(Tab.map)

            PluckerManagementView(container: container)
                .tabItem {
                    Label("Pluckers", systemImage: "person.3.fill")
                }
                .tag(Tab.pluckers)

            SupervisorSettingsView(container: container)
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.settings)
        }
        .tint(AppTheme.emerald)
        .applyAppTheme()
        .onChange(of: selectedTab) { _ in
            HapticFeedback.selection()
        }
    }
}

// MARK: - Previews

struct ManagerMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerMainTabView(container: AppContainer.shared)
    }
}


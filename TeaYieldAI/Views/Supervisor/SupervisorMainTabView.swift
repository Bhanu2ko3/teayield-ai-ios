import SwiftUI

/// Primary navigation shell for field supervisors providing the native 4-tab bottom bar.
/// Strictly conforms to Figma Screen 04, 06, 08, 09 specifications.
struct SupervisorMainTabView: View {

    private let container: AppContainerProtocol
    @State private var selectedTab: Tab = .tasks
    @State private var showingWeighingSheet: Bool = false

    enum Tab: Hashable {
        case tasks
        case scanner
        case map
        case settings
    }

    init(container: AppContainerProtocol) {
        self.container = container
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayTasksView(container: container)
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.clipboard")
                }
                .tag(Tab.tasks)

            LeafScannerPlaceholderView {
                showingWeighingSheet = true
            }
            .tabItem {
                Label("Scanner", systemImage: "viewfinder")
            }
            .tag(Tab.scanner)

            FieldMapPlaceholderView(fieldRepository: container.fieldRepository)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(Tab.map)

            SupervisorSettingsView(container: container)
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.settings)
        }
        .accentColor(AppTheme.emerald)
        .sheet(isPresented: $showingWeighingSheet) {
            HarvestWeighingFormView(viewModel: HarvestWeighingViewModel(
                harvestRepository: container.harvestRepository,
                fieldRepository: container.fieldRepository,
                syncManager: container.syncManager,
                authService: container.authService,
                apiService: container.apiService
            ))
        }
    }
}

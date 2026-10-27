import SwiftUI

/// Primary navigation shell for field supervisors providing the native 4-tab bottom bar.
/// Strictly conforms to Figma Screen 04, 06, 08, 09 specifications.
struct SupervisorMainTabView: View {

    private let container: AppContainerProtocol
    @State private var selectedTab: Tab = .tasks
    @State private var showingWeighingSheet: Bool = false
    @State private var scannedFineLeafRatio: Double? = nil
    @State private var preselectedFieldId: UUID? = nil

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

            LeafScannerView(
                viewModel: LeafScannerViewModel(
                    cameraService: container.cameraService,
                    classifier: container.leafClassifier
                ),
                onRecordWeighingTap: { ratio in
                    self.scannedFineLeafRatio = ratio
                    self.preselectedFieldId = nil
                    self.showingWeighingSheet = true
                }
            )
            .tabItem {
                Label("Scanner", systemImage: "viewfinder")
            }
            .tag(Tab.scanner)

            FieldMapView(
                viewModel: FieldMapViewModel(
                    fieldRepository: container.fieldRepository,
                    locationService: container.locationService
                ),
                onRecordWeighingTap: { field in
                    self.preselectedFieldId = field.id
                    self.scannedFineLeafRatio = nil
                    self.showingWeighingSheet = true
                }
            )
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
            weighingSheet
        }
    }

    @ViewBuilder
    private var weighingSheet: some View {
        let viewModel = HarvestWeighingViewModel(
            harvestRepository: container.harvestRepository,
            fieldRepository: container.fieldRepository,
            syncManager: container.syncManager,
            authService: container.authService,
            apiService: container.apiService
        )
        let _ = {
            if let ratio = scannedFineLeafRatio {
                viewModel.fineLeafRatio = ratio
            }
            if let fieldId = preselectedFieldId {
                viewModel.selectedFieldId = fieldId
            }
        }()

        HarvestWeighingFormView(viewModel: viewModel)
    }
    }
}

import SwiftUI

/// Main dashboard view for field supervisors managing daily plucking tasks, progress, and offline logs.
struct TodayTasksView: View {

    @StateObject private var viewModel: TodayTasksViewModel
    @State private var showingWeighingSheet = false
    @State private var selectedFieldForWeighing: UUID?

    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(wrappedValue: TodayTasksViewModel(
            apiService: container.apiService,
            syncManager: container.syncManager,
            fieldRepository: container.fieldRepository,
            harvestRepository: container.harvestRepository,
            authService: container.authService,
            locationService: container.locationService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        syncStatusSection
                        KpiSummaryRowView(
                            targetKg: viewModel.totalTargetKg,
                            harvestedKg: viewModel.totalHarvestedKg,
                            pluckersTotal: viewModel.assignedPluckersTotal
                        )
                        taskListSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.loadTodayTasks()
                }
            }
            .navigationTitle("Today's Operations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.emerald)
                        Text(viewModel.estateDisplayName)
                            .font(.appCallout)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            HarvestHistoryView(harvestRepository: container.harvestRepository)
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.emerald)
                        }
                        .accessibilityLabel("Weighing History")
                        .accessibilityHint("View locally cached green leaf weigh-in records from Core Data")

                        Button {
                            selectedFieldForWeighing = viewModel.tasks.first?.fieldId
                            showingWeighingSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Weigh Leaf")
                                    .font(.appCallout)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(AppTheme.emerald)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingWeighingSheet) {
                weighingSheetContent
            }
            .task {
                await viewModel.loadTodayTasks()
            }
            .alert("Operation Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred.")
            }
        }
    }

    // MARK: - Subviews

    private var syncStatusSection: some View {
        VStack(spacing: 12) {
            SyncStatusBarView(
                unsyncedCount: viewModel.unsyncedRecordsCount,
                isSyncing: viewModel.isSyncing,
                isOffline: viewModel.isOffline,
                statusMessage: viewModel.statusBannerMessage
            ) {
                Task {
                    await viewModel.triggerManualSync()
                }
            }

            if let activeField = viewModel.activeGeofencedField {
                GeofenceArrivalBannerView(
                    fieldName: activeField.name,
                    shiftDate: Date()
                ) {
                    selectedFieldForWeighing = activeField.id
                    showingWeighingSheet = true
                }
            } else if let activeTask = viewModel.tasks.first {
                GeofenceArrivalBannerView(
                    fieldName: activeTask.fieldName,
                    shiftDate: activeTask.shiftDate
                ) {
                    selectedFieldForWeighing = activeTask.fieldId
                    showingWeighingSheet = true
                }
            }
        }
    }

    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Assigned Fields")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            if viewModel.tasks.isEmpty && !viewModel.isLoading {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("No plucking tasks assigned for today.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.tasks) { task in
                    TaskCardView(task: task) {
                        selectedFieldForWeighing = task.fieldId
                        showingWeighingSheet = true
                    }
                    .contextMenu {
                        Button {
                            viewModel.simulateArrival(at: task)
                        } label: {
                            Label("Simulate Geofence Arrival", systemImage: "location.fill")
                        }

                        Button {
                            selectedFieldForWeighing = task.fieldId
                            showingWeighingSheet = true
                        } label: {
                            Label("Weigh Green Leaf", systemImage: "scalemass.fill")
                        }
                    }
                }
            }
        }
    }

    private var weighingSheetContent: some View {
        HarvestWeighingFormView(viewModel: HarvestWeighingViewModel(
            harvestRepository: container.harvestRepository,
            fieldRepository: container.fieldRepository,
            syncManager: container.syncManager,
            authService: container.authService,
            apiService: container.apiService,
            initialFieldId: selectedFieldForWeighing
        ))
        .onDisappear {
            Task {
                await viewModel.refreshPendingSyncCount()
            }
        }
    }
}

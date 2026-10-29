import SwiftUI

/// Main dashboard view for field supervisors managing daily plucking tasks, progress, and offline logs.
struct TodayTasksView: View {

    @StateObject private var viewModel: TodayTasksViewModel
    @State private var showingWeighingSheet = false
    @State private var showingProfileSheet = false
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
                    Button {
                        showingProfileSheet = true
                    } label: {
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
                    .accessibilityLabel("View enterprise officer profile")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        ThemeToggleView(style: .iconOnly)

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
            .sheet(isPresented: $showingProfileSheet) {
                UserProfileView(
                    authService: container.authService,
                    apiService: container.apiService,
                    harvestRepository: container.harvestRepository,
                    fieldRepository: container.fieldRepository
                )
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
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
            } else if !viewModel.tasks.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.emerald)
                    Text("Boundary Monitoring Active (\(viewModel.tasks.count) Assigned Fields)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("CoreLocation")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.06))
                .cornerRadius(AppTheme.radiusSmall)
            }
        }
    }

    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "ASSIGNED HARVEST BLOCKS",
                subtitle: "Daily plucking tasks optimized by Genetic Algorithm",
                icon: "leaf.fill",
                badge: viewModel.isLoading ? "SYNCING..." : "\(viewModel.tasks.count) FIELDS",
                badgeColor: AppTheme.emerald
            )

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
                    TaskCardView(
                        task: task,
                        isGeofenced: viewModel.activeGeofencedField?.id == task.fieldId,
                        onRecordWeighingTap: {
                            selectedFieldForWeighing = task.fieldId
                            showingWeighingSheet = true
                        },
                        onSimulateArrivalTap: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                if viewModel.activeGeofencedField?.id == task.fieldId {
                                    viewModel.simulateExit()
                                } else {
                                    viewModel.simulateArrival(at: task)
                                }
                            }
                        }
                    )
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
        .applyAppTheme()
        .onDisappear {
            Task {
                await viewModel.refreshPendingSyncCount()
            }
        }
    }
}

// MARK: - Previews

struct TodayTasksView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTasksView(container: AppContainer.shared)
    }
}


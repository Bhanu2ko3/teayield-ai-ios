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
            authService: container.authService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        syncStatusHeader
                        kpiSummaryRow
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
                        container.authService.logout()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedFieldForWeighing = viewModel.tasks.first?.fieldId
                        showingWeighingSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Weigh Leaf")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
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

    private var syncStatusHeader: some View {
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
    }

    private var kpiSummaryRow: some View {
        HStack(spacing: 12) {
            kpiCard(
                title: "Target Yield",
                value: String(format: "%.0f kg", viewModel.totalTargetKg),
                icon: "target",
                tintColor: .blue
            )

            kpiCard(
                title: "Harvested",
                value: String(format: "%.0f kg", viewModel.totalHarvestedKg),
                icon: "scalemass.fill",
                tintColor: Color(red: 0.02, green: 0.59, blue: 0.41)
            )

            kpiCard(
                title: "Pluckers",
                value: "\(viewModel.assignedPluckersTotal)",
                icon: "person.2.fill",
                tintColor: .purple
            )
        }
    }

    private func kpiCard(title: String, value: String, icon: String, tintColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(tintColor)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
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

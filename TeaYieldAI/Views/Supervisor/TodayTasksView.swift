import SwiftUI

/// Main dashboard view for field supervisors managing daily plucking tasks, progress, and offline logs.
struct TodayTasksView: View {

    @AppStorage("requireFaceIDOnLaunch") private var requireFaceIDOnLaunch: Bool = true
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
                    VStack(spacing: 16) {
                        supervisorProfileHeader
                        syncStatusSection
                        KpiSummaryRowView(
                            targetKg: viewModel.totalTargetKg,
                            harvestedKg: viewModel.totalHarvestedKg,
                            pluckersTotal: viewModel.assignedPluckersTotal
                        )
                        taskListSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .refreshable {
                    await viewModel.loadTodayTasks()
                }
            }
            .navigationTitle("Today's Operations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if requireFaceIDOnLaunch {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            HapticFeedback.selection()
                            NotificationCenter.default.post(name: Notification.Name("TeaYieldLockAppRequested"), object: nil)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 15))
                                Text("Lock")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.emerald)
                        }
                        .accessibilityLabel("Lock application immediately with Face ID")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            HarvestHistoryView(harvestRepository: container.harvestRepository)
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.emerald)
                        }
                        .accessibilityLabel("Weighing History")
                        .accessibilityHint("View locally cached green leaf weigh-in records from verified repository")

                        Button {
                            showingProfileSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.emerald)
                        }
                        .accessibilityLabel("View enterprise officer profile")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
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

    private var supervisorProfileHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundColor(AppTheme.emerald)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.supervisorName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text(viewModel.supervisorRoleTitle)
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    selectedFieldForWeighing = viewModel.tasks.first?.fieldId
                    showingWeighingSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Weigh Leaf")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(AppTheme.emerald)
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel("Record Leaf Weighing")
            }

            Divider()

            HStack {
                HStack(spacing: 6) {
                    Text("EMPLOYEE ID")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(viewModel.supervisorEmployeeId)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.emerald)
                    Text(viewModel.estateDisplayName)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

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
                    Text("GPS Geofence")
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

            if viewModel.isLoading && viewModel.tasks.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.emerald))
                        .scaleEffect(1.1)

                    Text("Synchronizing Assigned Harvest Blocks...")
                        .font(.appCallout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
            } else if viewModel.tasks.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 38))
                        .foregroundColor(.secondary)

                    VStack(spacing: 4) {
                        Text("No plucking tasks assigned for today.")
                            .font(.appHeadline)
                            .foregroundColor(.primary)

                        Text("Daily harvesting tasks scheduled by the Genetic Algorithm optimizer will populate here.")
                            .font(.appCaption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Button {
                        selectedFieldForWeighing = nil
                        showingWeighingSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill")
                            Text("Record Field Weigh-In")
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(AppTheme.emerald.opacity(0.12))
                        .cornerRadius(AppTheme.radiusMedium)
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
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
                await viewModel.loadTodayTasks()
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


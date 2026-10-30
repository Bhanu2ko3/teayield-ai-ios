import SwiftUI

/// Dedicated full-lifecycle workforce management screen for estate pluckers (Component 2 & 5).
/// Supports search filtering, productivity analytics, inline active status toggles, editing, and deletion.
struct PluckerManagementView: View {

    @StateObject private var viewModel: PluckerManagementViewModel
    private let container: AppContainerProtocol

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: PluckerManagementViewModel(
                apiService: container.apiService,
                authService: container.authService
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Summary Metric Banner
                        workforceSummaryBanner

                        // Search Bar
                        TeaYieldSearchBar(
                            text: $viewModel.searchText,
                            placeholder: "Search by plucker name or code..."
                        )

                        // Plucker List
                        if viewModel.isLoading && viewModel.pluckers.isEmpty {
                            ProgressView("Synchronizing workforce...")
                                .padding(.top, 40)
                        } else if viewModel.filteredPluckers.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredPluckers) { plucker in
                                    pluckerCard(plucker)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .refreshable {
                    await viewModel.loadPluckers()
                }
            }
            .navigationTitle("Plucker Workforce")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isShowingAddPluckerSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Enroll")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.emerald)
                    }
                    .accessibilityLabel("Enroll new plucker worker")
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddPluckerSheet) {
                if let estateId = viewModel.activeEstateId {
                    AddPluckerSheetView(
                        apiService: container.apiService,
                        estateId: estateId,
                        onCreated: {
                            Task {
                                await viewModel.loadPluckers()
                            }
                        }
                    )
                }
            }
            .sheet(item: $viewModel.editingPlucker) { plucker in
                EditPluckerSheetView(
                    apiService: container.apiService,
                    plucker: plucker,
                    onUpdated: {
                        Task {
                            await viewModel.loadPluckers()
                        }
                    }
                )
            }
            .confirmationDialog(
                "Deregister Plucker?",
                isPresented: $viewModel.isShowingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: viewModel.pluckerToDelete
            ) { plucker in
                Button("Deregister \(plucker.fullName)", role: .destructive) {
                    Task {
                        await viewModel.deletePlucker(plucker)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { plucker in
                Text("Are you sure you want to remove \(plucker.pluckerCode) - \(plucker.fullName) from the plantation registry?")
            }
            .task {
                await viewModel.loadPluckers()
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var workforceSummaryBanner: some View {
        HStack(spacing: 12) {
            summaryMetricItem(
                title: "Enrolled",
                value: "\(viewModel.pluckers.count)",
                icon: "person.3.fill",
                color: .blue
            )

            summaryMetricItem(
                title: "Active Duty",
                value: "\(viewModel.activePluckersCount)",
                icon: "checkmark.circle.fill",
                color: AppTheme.emerald
            )

            summaryMetricItem(
                title: "Avg Rate",
                value: String(format: "%.1f kg", viewModel.averageProductivityRate),
                icon: "scalemass.fill",
                color: AppTheme.amber
            )
        }
    }

    private func summaryMetricItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(color)
                Text(title)
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search by name or badge code...", text: $viewModel.searchText)
                .font(.appBody)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
    }

    private func pluckerCard(_ plucker: Plucker) -> some View {
        HStack(spacing: 12) {
            // Avatar badge
            ZStack {
                Circle()
                    .fill(plucker.isActive ? AppTheme.emerald.opacity(0.14) : Color.secondary.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.fill")
                    .foregroundColor(plucker.isActive ? AppTheme.emerald : .secondary)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(plucker.fullName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text(plucker.pluckerCode)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(AppTheme.radiusSmall)
                }

                Text("Productivity: \(plucker.formattedAverageRate)")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status Pill & Action Menu
            VStack(alignment: .trailing, spacing: 6) {
                Menu {
                    Button {
                        viewModel.editingPlucker = plucker
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }

                    Button {
                        Task {
                            await viewModel.toggleActiveStatus(for: plucker)
                        }
                    } label: {
                        Label(
                            plucker.isActive ? "Mark Inactive" : "Mark Active",
                            systemImage: plucker.isActive ? "pause.circle" : "play.circle"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        viewModel.pluckerToDelete = plucker
                        viewModel.isShowingDeleteConfirmation = true
                    } label: {
                        Label("Deregister", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .padding(4)
                }

                Text(plucker.isActive ? "ACTIVE" : "INACTIVE")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(plucker.isActive ? AppTheme.emerald : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        (plucker.isActive ? AppTheme.emerald : Color.secondary).opacity(0.12)
                    )
                    .cornerRadius(AppTheme.radiusSmall)
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.slash")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 24)

            Text("No Pluckers Found")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("Enroll new workforce harvesters or adjust your search filter.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

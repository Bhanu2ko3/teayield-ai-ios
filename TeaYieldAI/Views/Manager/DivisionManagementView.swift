import SwiftUI

/// Dedicated full-lifecycle estate divisions and blocks management screen (Component 2 & 5).
/// Matches PluckerManagementView structure with search filtering, status segmentation, full CRUD editing, and deletion.
struct DivisionManagementView: View {

    @ObservedObject var viewModel: ManagerOverviewViewModel
    private let container: AppContainerProtocol
    @State private var searchText: String = ""
    @State private var selectedFilter: StatusFilter = .all
    @State private var isShowingAddSheet: Bool = false
    @State private var editingField: TeaField? = nil
    @State private var fieldToDelete: TeaField? = nil
    @State private var isShowingDeleteConfirmation: Bool = false

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case ready = "Ready"
        case growing = "Growing"
        case resting = "Resting"

        var id: String { rawValue }
    }

    init(container: AppContainerProtocol, viewModel: ManagerOverviewViewModel) {
        self.container = container
        self.viewModel = viewModel
    }

    private var filteredFields: [TeaField] {
        viewModel.fields.filter { field in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all: matchesFilter = true
            case .ready: matchesFilter = field.status == .ready
            case .growing: matchesFilter = field.status == .growing
            case .resting: matchesFilter = field.status == .resting
            }

            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = trimmed.isEmpty ||
                field.name.lowercased().contains(trimmed) ||
                field.blockCode.lowercased().contains(trimmed)

            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Summary Metric Banner
                        divisionsSummaryBanner

                        // Search Bar
                        TeaYieldSearchBar(
                            text: $searchText,
                            placeholder: "Search block code or division name..."
                        )

                        // Filter Segmented Picker
                        filterSegmentedControl

                        // Divisions List
                        if viewModel.isLoading && viewModel.fields.isEmpty {
                            ProgressView("Synchronizing field divisions...")
                                .padding(.top, 40)
                        } else if filteredFields.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredFields) { field in
                                    ManagerFieldRowView(
                                        field: field,
                                        onEdit: {
                                            editingField = field
                                        },
                                        onDelete: {
                                            fieldToDelete = field
                                            isShowingDeleteConfirmation = true
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .refreshable {
                    await viewModel.loadEstateTelemetry()
                }
            }
            .navigationTitle("Estate Divisions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("New Block")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.emerald)
                    }
                    .accessibilityLabel("Add new tea field division")
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                if let estateId = container.authService.currentUser?.estateId {
                    AddFieldDivisionSheetView(
                        apiService: container.apiService,
                        estateId: estateId,
                        onCreated: {
                            Task {
                                await viewModel.loadEstateTelemetry()
                            }
                        }
                    )
                }
            }
            .sheet(item: $editingField) { field in
                EditFieldDivisionSheetView(
                    field: field,
                    onUpdated: { updated in
                        Task {
                            await viewModel.updateFieldLocally(updated)
                        }
                    }
                )
            }
            .confirmationDialog(
                "Retire Field Division?",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: fieldToDelete
            ) { field in
                Button("Retire \(field.name)", role: .destructive) {
                    Task {
                        await viewModel.deleteFieldLocally(field)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { field in
                Text("Are you sure you want to retire \(field.blockCode) (\(field.name)) from active plantation telemetry? Historical logs will remain archived.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var divisionsSummaryBanner: some View {
        HStack(spacing: 12) {
            summaryMetricItem(
                title: "Total Blocks",
                value: "\(viewModel.fields.count)",
                icon: "leaf.fill",
                color: AppTheme.emerald
            )

            summaryMetricItem(
                title: "Total Acreage",
                value: String(format: "%.1f Ac", viewModel.totalAcreage),
                icon: "square.dashed",
                color: .blue
            )

            summaryMetricItem(
                title: "Harvest Ready",
                value: "\(viewModel.readyFieldsCount)",
                icon: "checkmark.circle.fill",
                color: AppTheme.emerald
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

            TextField("Search block code or division name...", text: $searchText)
                .font(.appBody)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
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

    private var filterSegmentedControl: some View {
        Picker("Filter Status", selection: $selectedFilter) {
            ForEach(StatusFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.top, 24)

            Text("No Field Divisions Found")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text(searchText.isEmpty ? "Tap 'New Block' above to register your first tea division block." : "No divisions matching '\(searchText)'.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}


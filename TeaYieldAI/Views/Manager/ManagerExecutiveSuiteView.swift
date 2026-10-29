import SwiftUI
import MapKit

/// Desktop-class iPad executive suite utilizing modern iOS 16 NavigationSplitView (Component 5).
/// Dynamically delivers a multi-pane operational canvas for estate managers and agronomy directors.
struct ManagerExecutiveSuiteView: View {

    private let container: AppContainerProtocol
    @StateObject private var viewModel: ManagerOverviewViewModel
    @State private var selectedNavigationItem: ExecutiveNavDestination? = .overview
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var expandedFieldId: UUID? = nil
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue
    @Namespace private var fieldCardAnimation

    enum ExecutiveNavDestination: String, CaseIterable, Identifiable {
        case overview = "Executive Overview"
        case spatialMap = "Estate Spatial GIS"
        case yieldAnalytics = "Harvest Analytics"
        case fieldRoster = "Division Blocks"
        case teamDelegation = "Staff Delegation"
        case profile = "Officer Profile"
        case diagnostics = "Offline & Diagnostics"

        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .overview: return "square.grid.2x2.fill"
            case .spatialMap: return "map.fill"
            case .yieldAnalytics: return "chart.bar.xaxis"
            case .fieldRoster: return "leaf.fill"
            case .teamDelegation: return "person.badge.shield.checkmark.fill"
            case .profile: return "person.crop.circle.fill"
            case .diagnostics: return "gearshape.fill"
            }
        }
    }

    init(container: AppContainerProtocol) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: ManagerOverviewViewModel(
                fieldRepository: container.fieldRepository,
                harvestRepository: container.harvestRepository,
                authService: container.authService,
                apiService: container.apiService
            )
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarContent
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            await viewModel.loadEstateTelemetry()
        }
        .applyAppTheme()
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        List(selection: $selectedNavigationItem) {
            Section {
                sidebarManagerHeader
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section(header: Text("OPERATIONAL SUITE")) {
                ForEach(ExecutiveNavDestination.allCases) { item in
                    NavigationLink(value: item) {
                        Label {
                            HStack {
                                Text(item.rawValue)
                                    .font(.appBody)
                                    .fontWeight(.medium)
                                Spacer()
                                if item == .fieldRoster && viewModel.readyFieldsCount > 0 {
                                    Text("\(viewModel.readyFieldsCount) Ready")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.emerald.opacity(0.18))
                                        .foregroundColor(AppTheme.emerald)
                                        .cornerRadius(4)
                                }
                            }
                        } icon: {
                            Image(systemName: item.iconName)
                                .foregroundColor(selectedNavigationItem == item ? AppTheme.emerald : .secondary)
                        }
                    }
                }
            }

            Section(header: Text("APPEARANCE")) {
                Picker("Theme", selection: $appThemeMode) {
                    ForEach(AppThemeMode.allCases) { mode in
                        Text(mode.shortTitle).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                ambientConnectionStatus
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.sidebar)
        .navigationTitle("TeaYield Executive")
        .onChange(of: selectedNavigationItem) { _ in
            HapticFeedback.selection()
        }
    }

    private var sidebarManagerHeader: some View {
        Button {
            selectedNavigationItem = .profile
            HapticFeedback.selection()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(AppTheme.emerald)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.managerName.isEmpty ? "Estate Manager" : viewModel.managerName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                    Text(viewModel.estateDisplayName)
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var ambientConnectionStatus: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.emerald)
                .frame(width: 8, height: 8)
            Text("Edge Engine Connected • Local SQLite Active")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Detail Canvas (Adaptive iPad Wide Screen)

    @ViewBuilder
    private var detailContent: some View {
        switch selectedNavigationItem ?? .overview {
        case .overview:
            executiveOverviewCanvas
        case .spatialMap:
            FieldMapView(
                fieldRepository: container.fieldRepository,
                locationService: container.locationService,
                apiService: container.apiService,
                authService: container.authService
            )
        case .yieldAnalytics:
            ManagerAnalyticsDashboardView(viewModel: viewModel)
        case .fieldRoster:
            divisionRosterGrid
        case .teamDelegation:
            InviteSupervisorSheetView(apiService: container.apiService)
        case .profile:
            UserProfileView(
                authService: container.authService,
                apiService: container.apiService,
                harvestRepository: container.harvestRepository,
                fieldRepository: container.fieldRepository
            )
        case .diagnostics:
            SupervisorSettingsView(container: container)
        }
    }

    // MARK: - Executive Overview Canvas (Side-by-Side iPad Layout)

    private var executiveOverviewCanvas: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Executive KPI Row
                HStack(spacing: 14) {
                    kpiMetricCard(
                        title: "Total Acreage",
                        value: String(format: "%.1f ac", viewModel.totalAcreage),
                        subtext: "\(viewModel.fields.count) Commercial Blocks",
                        icon: "square.dashed",
                        color: .blue
                    )

                    kpiMetricCard(
                        title: "Today's Intake",
                        value: String(format: "%.0f kg", viewModel.totalHarvestTodayKg),
                        subtext: "\(String(format: "%.0f%%", viewModel.factoryUtilizationRatio * 100.0)) Withering Cap",
                        icon: "scalemass.fill",
                        color: AppTheme.emerald
                    )

                    kpiMetricCard(
                        title: "Harvest-Ready",
                        value: "\(viewModel.readyFieldsCount)",
                        subtext: "\(viewModel.growingFieldsCount) Growing • \(viewModel.restingFieldsCount) Resting",
                        icon: "leaf.fill",
                        color: AppTheme.amber
                    )

                    kpiMetricCard(
                        title: "Export Quality",
                        value: String(format: "%.1f%%", viewModel.averageFineLeafPercentage),
                        subtext: "TRI Standard (85%)",
                        icon: "rosette",
                        color: AppTheme.emerald
                    )
                }

                // Two-Column Side-by-Side iPad Analytics Layout
                HStack(alignment: .top, spacing: 20) {
                    VStack(spacing: 20) {
                        FactoryCapacityChartView(
                            currentIntakeKg: viewModel.totalHarvestTodayKg,
                            capacityCapKg: viewModel.factoryIntakeCapKg,
                            utilizationRatio: viewModel.factoryUtilizationRatio,
                            remainingCapacityKg: viewModel.remainingCapacityKg
                        )

                        // Quick division readiness summary
                        divisionStatusSummaryCard
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 20) {
                        YieldComparisonChartView(data: viewModel.weeklyYieldComparisons)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Executive Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func kpiMetricCard(title: String, value: String, subtext: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Text(subtext)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(color)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private var divisionStatusSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estate Division Balance")
                .font(.appHeadline)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                statusPill(title: "Ready (\(viewModel.readyFieldsCount))", color: AppTheme.emerald)
                statusPill(title: "Growing (\(viewModel.growingFieldsCount))", color: AppTheme.amber)
                statusPill(title: "Resting (\(viewModel.restingFieldsCount))", color: AppTheme.crimson)
            }

            Text("Optimal harvesting equilibrium maintains continuous green leaf supply to avoid factory withering trough under-utilization.")
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func statusPill(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .cornerRadius(8)
    }

    // MARK: - Division Inventory Grid with Matched Geometry

    private var divisionRosterGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                ForEach(viewModel.fields) { field in
                    divisionCard(field: field)
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Division Inventory")
    }

    private func divisionCard(field: TeaField) -> some View {
        let isExpanded = expandedFieldId == field.id

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(field.name)
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                    Text("Block: \(field.blockCode)")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(field.status.displayName)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor(for: field.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: field.status).opacity(0.15))
                    .cornerRadius(6)
            }

            Divider()

            HStack {
                Label(field.formattedAcreage, systemImage: "square.dashed")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                Label(String(format: "NDVI %.2f", field.currentNDVI), systemImage: "leaf.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(statusColor(for: field.status))
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Coordinates: \(String(format: "%.4f, %.4f", field.centroidLatitude, field.centroidLongitude))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text("Est. Harvest Yield: \(String(format: "%.0f kg", field.acreage * AppConfiguration.benchmarkYieldPerAcreKg))")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .matchedGeometryEffect(id: field.id, in: fieldCardAnimation)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                if expandedFieldId == field.id {
                    expandedFieldId = nil
                } else {
                    expandedFieldId = field.id
                    HapticFeedback.lightImpact()
                }
            }
        }
    }

    private func statusColor(for status: FieldReadinessStatus) -> Color {
        switch status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }
}

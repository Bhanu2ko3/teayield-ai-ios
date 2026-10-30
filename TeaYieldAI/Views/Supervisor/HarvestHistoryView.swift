import SwiftUI

/// View displaying historically recorded green leaf weighing logs with quality grades, time range filtering, and multi-criteria sorting.
/// Conforms strictly to Section 5 Design System and eliminates all tech-stack leaks.
struct HarvestHistoryView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HarvestHistoryViewModel

    init(
        harvestRepository: HarvestRepositoryProtocol,
        apiService: APIServiceProtocol? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: HarvestHistoryViewModel(
                harvestRepository: harvestRepository,
                apiService: apiService
            )
        )
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    summaryHeaderCard
                    timeRangeSelector
                    controlsRow
                    TeaYieldSearchBar(
                        text: $viewModel.searchText,
                        placeholder: "Search by plucker name or ID..."
                    )
                    recordsListSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .refreshable {
                await viewModel.loadRecords()
            }
        }
        .navigationTitle("Weighing History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
        .task {
            await viewModel.loadRecords()
        }
        .applyAppTheme()
    }

    // MARK: - Subviews

    private var summaryHeaderCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Harvest")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f kg", viewModel.totalHarvestedKg))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .frame(height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text("Average Fine Leaf")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f%%", viewModel.averageFineLeafRatio * 100))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .frame(height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text("Total Logs")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text("\(viewModel.filteredRecordsCount)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    // MARK: - Time Range Filter Tabs

    private var timeRangeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HarvestHistoryViewModel.TimeRangeOption.allCases) { range in
                    Button {
                        HapticFeedback.selection()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.timeRangeSelection = range
                        }
                    } label: {
                        Text(range.rawValue)
                            .font(.system(size: 12, weight: viewModel.timeRangeSelection == range ? .bold : .medium, design: .rounded))
                            .foregroundColor(viewModel.timeRangeSelection == range ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(viewModel.timeRangeSelection == range ? AppTheme.emerald : Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(AppTheme.radiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                                    .stroke(viewModel.timeRangeSelection == range ? AppTheme.emerald : Color.secondary.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Filter & Sort Controls Row

    private var controlsRow: some View {
        HStack(spacing: 10) {
            // Segmented Sync Status Picker
            Picker("Filter Logs", selection: $viewModel.filterSelection) {
                ForEach(HarvestHistoryViewModel.SyncFilterOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.filterSelection) { _ in
                HapticFeedback.selection()
            }

            // Sort Menu Dropdown
            Menu {
                Picker("Sort Order", selection: $viewModel.sortSelection) {
                    ForEach(HarvestHistoryViewModel.SortOption.allCases) { option in
                        Label(option.rawValue, systemImage: sortIcon(for: option))
                            .tag(option)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .bold))
                    Text("Sort")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(AppTheme.emerald)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppTheme.emerald.opacity(0.12))
                .cornerRadius(AppTheme.radiusSmall)
            }
        }
    }

    private func sortIcon(for option: HarvestHistoryViewModel.SortOption) -> String {
        switch option {
        case .newestFirst: return "clock.arrow.circlepath"
        case .oldestFirst: return "clock"
        case .highestWeight: return "scalemass.fill"
        case .lowestWeight: return "scalemass"
        case .highestQuality: return "rosette"
        }
    }

    // MARK: - Records List

    private var recordsListSection: some View {
        VStack(spacing: 10) {
            if viewModel.filteredRecords.isEmpty && !viewModel.isLoading {
                emptyStateCard
            } else {
                ForEach(viewModel.filteredRecords) { record in
                    HarvestRecordRowView(record: record)
                }
            }
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: "scalemass.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.emerald)
            }
            .padding(.top, 4)

            Text("No Weighing Records Found")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("No green leaf logs match the selected time range or filter criteria. Recorded logs will appear here immediately.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

// MARK: - Previews

struct HarvestHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HarvestHistoryView(harvestRepository: AppContainer.shared.harvestRepository)
        }
    }
}

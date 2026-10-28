import SwiftUI

/// View displaying historically recorded green leaf weighing logs retrieved directly from Core Data.
struct HarvestHistoryView: View {

    @StateObject private var viewModel: HarvestHistoryViewModel

    init(harvestRepository: HarvestRepositoryProtocol) {
        _viewModel = StateObject(
            wrappedValue: HarvestHistoryViewModel(harvestRepository: harvestRepository)
        )
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    summaryHeaderCard
                    filterSegmentedPicker
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
        .searchable(text: $viewModel.searchText, prompt: "Search by plucker name or ID")
        .task {
            await viewModel.loadRecords()
        }
        .applyAppTheme()
    }

    // MARK: - Subviews

    private var summaryHeaderCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Harvest Logged")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f kg", viewModel.totalHarvestedKg))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Average Fine Leaf")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.1f%%", viewModel.averageFineLeafRatio * 100))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private var filterSegmentedPicker: some View {
        Picker("Filter Logs", selection: $viewModel.filterSelection) {
            ForEach(HarvestHistoryViewModel.FilterOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }

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
            Image(systemName: "tray.fill")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))

            Text("No Weighing Logs Found")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("Saved green leaf weigh-ins and fine leaf ratio inspection grades will populate here from local Core Data storage.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

import SwiftUI

/// View displaying historically recorded green leaf weighing logs with quality grades and sync status.
/// Conforms strictly to Section 5 Design System and eliminates all tech-stack leaks.
struct HarvestHistoryView: View {

    @Environment(\.dismiss) private var dismiss
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
                    searchFieldSection
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.appBody)
                    }
                    .foregroundColor(AppTheme.emerald)
                }
                .accessibilityLabel("Navigate back")
            }
        }
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

                Text("\(viewModel.records.count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var filterSegmentedPicker: some View {
        Picker("Filter Logs", selection: $viewModel.filterSelection) {
            ForEach(HarvestHistoryViewModel.FilterOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.filterSelection) { _ in
            HapticFeedback.selection()
        }
    }

    private var searchFieldSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14))

            TextField("Search by plucker name or ID", text: $viewModel.searchText)
                .font(.appBody)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    HapticFeedback.selection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
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

            Text("Saved green leaf weigh-ins and fine leaf ratio inspection grades will populate here once recorded from field blocks.")
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

import SwiftUI
import MapKit

/// Primary spatial GIS interface displaying color-coded vector field boundaries and estate geofences (Component 3).
struct FieldMapView: View {

    @StateObject private var viewModel: FieldMapViewModel
    var onRecordWeighingTap: ((TeaField) -> Void)?

    init(
        viewModel: FieldMapViewModel,
        onRecordWeighingTap: ((TeaField) -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onRecordWeighingTap = onRecordWeighingTap
    }

    init(
        fieldRepository: FieldRepositoryProtocol,
        locationService: LocationServiceProtocol,
        onRecordWeighingTap: ((TeaField) -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: FieldMapViewModel(
                fieldRepository: fieldRepository,
                locationService: locationService
            )
        )
        self.onRecordWeighingTap = onRecordWeighingTap
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Interactive MapKit View
                InteractiveMapView(
                    fields: viewModel.filteredFields,
                    selectedField: viewModel.selectedField,
                    mapType: viewModel.mapType,
                    cameraRegion: viewModel.cameraRegion,
                    onSelectField: { field in
                        viewModel.selectField(field)
                    }
                )
                .ignoresSafeArea(edges: .all)

                // Top Floating Control Bar
                VStack(spacing: 8) {
                    topFilterBar
                    Spacer()
                }

                // Bottom Selected Field Card or Floating Controls
                if let selected = viewModel.selectedField {
                    FieldDetailBottomSheetView(
                        field: selected,
                        isCurrentlyGeofenced: viewModel.activeGeofencedField?.id == selected.id,
                        onWeighTap: { field in
                            onRecordWeighingTap?(field)
                        },
                        onSimulateGeofenceTap: { field in
                            viewModel.simulateGeofenceArrival(at: field)
                        },
                        onCloseTap: {
                            viewModel.selectedField = nil
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }

                // Loading Indicator
                if viewModel.isLoading {
                    ProgressView("Loading Estate GIS...")
                        .padding()
                        .background(AppTheme.surfaceGlass)
                        .cornerRadius(12)
                        .padding(.bottom, 60)
                }
            }
            .navigationTitle("Estate GIS Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.resetCameraToEstate() }) {
                        Image(systemName: "location.fill")
                    }

                    Button(action: { viewModel.toggleMapType() }) {
                        Image(systemName: viewModel.mapType == .hybrid ? "map" : "globe.americas.fill")
                    }
                }
            }
            .task {
                await viewModel.loadFields()
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedField)
            .applyAppTheme()
        }
    }

    // MARK: - Top Floating Filter Bar

    private var topFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterPill(
                    title: "All Divisions (\(viewModel.fields.count))",
                    isSelected: viewModel.filterStatus == nil,
                    color: .primary
                ) {
                    viewModel.setFilter(nil)
                }

                filterPill(
                    title: "Ready (\(viewModel.harvestReadyCount))",
                    isSelected: viewModel.filterStatus == .ready,
                    color: AppTheme.emerald
                ) {
                    viewModel.setFilter(.ready)
                }

                filterPill(
                    title: "Growing (\(viewModel.growingCount))",
                    isSelected: viewModel.filterStatus == .growing,
                    color: AppTheme.amber
                ) {
                    viewModel.setFilter(.growing)
                }

                filterPill(
                    title: "Resting (\(viewModel.restingCount))",
                    isSelected: viewModel.filterStatus == .resting,
                    color: AppTheme.crimson
                ) {
                    viewModel.setFilter(.resting)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func filterPill(title: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.secondary.opacity(0.12))
                .cornerRadius(14)
        }
    }
}

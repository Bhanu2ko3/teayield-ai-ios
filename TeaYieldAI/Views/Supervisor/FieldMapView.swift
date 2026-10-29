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
        apiService: APIServiceProtocol? = nil,
        authService: AuthServiceProtocol? = nil,
        onRecordWeighingTap: ((TeaField) -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: FieldMapViewModel(
                fieldRepository: fieldRepository,
                locationService: locationService,
                apiService: apiService,
                authService: authService
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

                // Top Floating Header & Filter Control Bar
                VStack(spacing: 8) {
                    topHeaderBar
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
                        .cornerRadius(AppTheme.radiusMedium)
                        .padding(.bottom, 60)
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.loadFields()
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedField)
            .applyAppTheme()
        }
    }

    // MARK: - Top Header Bar

    private var topHeaderBar: some View {
        HStack {
            Text("Estate GIS Map")
                .font(.appHeadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.surfaceGlass)
                .cornerRadius(AppTheme.radiusMedium)
                .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    HapticFeedback.lightImpact()
                    viewModel.resetCameraToEstate()
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.emerald)
                        .frame(width: 36, height: 36)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
                }
                .accessibilityLabel("Center map on estate")

                Button(action: {
                    HapticFeedback.selection()
                    viewModel.toggleMapType()
                }) {
                    Image(systemName: viewModel.mapType == .hybrid ? "map.fill" : "globe.americas.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.emerald)
                        .frame(width: 36, height: 36)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
                }
                .accessibilityLabel("Toggle satellite or standard map layer")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
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
        Button {
            HapticFeedback.selection()
            action()
        } label: {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.secondary.opacity(0.12))
                .cornerRadius(AppTheme.radiusPill)
        }
    }
}

// MARK: - Previews

struct FieldMapView_Previews: PreviewProvider {
    static var previews: some View {
        FieldMapView(
            fieldRepository: AppContainer.shared.fieldRepository,
            locationService: AppContainer.shared.locationService,
            apiService: AppContainer.shared.apiService,
            authService: AppContainer.shared.authService
        )
    }
}


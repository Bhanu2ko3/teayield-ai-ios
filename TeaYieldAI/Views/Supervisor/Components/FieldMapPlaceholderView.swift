import SwiftUI

/// Spatial GIS overview displaying real cached tea field divisions from Core Data with satellite NDVI status.
struct FieldMapPlaceholderView: View {

    private let fieldRepository: FieldRepositoryProtocol
    @State private var fields: [TeaField] = []
    @State private var isLoading: Bool = false

    init(fieldRepository: FieldRepositoryProtocol) {
        self.fieldRepository = fieldRepository
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        heroHeaderSection
                        divisionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await loadCachedFields()
                }
            }
            .navigationTitle("Field Map")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadCachedFields()
            }
        }
    }

    // MARK: - Subviews

    private var heroHeaderSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 80, height: 80)

                Image(systemName: "map.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 4) {
                Text("Spatial Field GIS & Geofencing")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("MapKit Polygons • CoreLocation Monitoring")
                    .font(.appCallout)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)

                Text("Interactive vector overlays color-coded by Sentinel-2 NDVI health alongside low-power background circular region alerts for estate divisions.")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 8)
    }

    private var divisionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CACHED FIELD DIVISIONS (CORE DATA)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)

                Spacer()

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Text("\(fields.count) Blocks")
                        .font(.appBadge)
                        .foregroundColor(.secondary)
                }
            }

            if fields.isEmpty && !isLoading {
                emptyDatabasePlaceholder
            } else {
                VStack(spacing: 10) {
                    ForEach(fields) { field in
                        fieldDivisionRow(field: field)
                    }
                }
            }
        }
    }

    private var emptyDatabasePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.slash")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))

            Text("No Field Polygons in Local Database")
                .font(.appHeadline)
                .foregroundColor(.primary)

            Text("Field GIS boundaries and NDVI health indexes will populate here after synchronizing with the estate server.")
                .font(.appCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func fieldDivisionRow(field: TeaField) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor(for: field.status))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(field.name)
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Acreage: \(field.formattedAcreage) • Block: \(field.blockCode)")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(field.status.rawValue)
                    .font(.appBadge)
                    .foregroundColor(statusColor(for: field.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor(for: field.status).opacity(0.12))
                    .cornerRadius(6)

                Text("NDVI \(field.formattedNDVI)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private func statusColor(for status: FieldReadinessStatus) -> Color {
        switch status {
        case .ready: return AppTheme.emerald
        case .growing: return AppTheme.amber
        case .resting: return AppTheme.crimson
        }
    }

    private func loadCachedFields() async {
        isLoading = true
        do {
            let fetched = try await fieldRepository.fetchAllFields()
            await MainActor.run {
                self.fields = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// MARK: - Previews

struct FieldMapPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        FieldMapPlaceholderView(fieldRepository: AppContainer.shared.fieldRepository)
    }
}


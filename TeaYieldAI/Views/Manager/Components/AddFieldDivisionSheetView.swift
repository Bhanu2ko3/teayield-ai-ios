import SwiftUI

/// Modal sheet enabling estate managers to register a new spatial tea field division.
struct AddFieldDivisionSheetView: View {

    @Environment(\.dismiss) private var dismiss
    private let apiService: APIServiceProtocol
    private let estateId: UUID
    private let onCreated: () -> Void

    @State private var fieldName: String = ""
    @State private var acreageInput: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false

    init(
        apiService: APIServiceProtocol,
        estateId: UUID,
        onCreated: @escaping () -> Void
    ) {
        self.apiService = apiService
        self.estateId = estateId
        self.onCreated = onCreated
    }

    private var isFormValid: Bool {
        let trimmed = fieldName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 && trimmed.count <= 100 else { return false }
        guard let acres = Double(InputSanitizer.sanitizeDecimal(acreageInput)), acres >= 0.5 && acres <= 500.0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        formCard
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Field Division")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Registration Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Could not register new field block.")
            }
            .applyAppTheme()
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "DIVISION DETAILS",
                subtitle: "Register tea block for Sentinel-2 satellite canopy monitoring",
                icon: "leaf.fill"
            )

            // Field Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Division Designation")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Upper Ridge Division Block G", text: $fieldName)
                        .font(.appBody)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Acreage
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Surveyed Acreage")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("0.5 – 500.0 Ac")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "square.dashed")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 18.5", text: $acreageInput)
                        .keyboardType(.decimalPad)
                        .onChange(of: acreageInput) { newValue in
                            acreageInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("Acres")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            TeaYieldButton(
                title: "Register Field Division",
                icon: "plus.circle.fill",
                style: .primary,
                isLoading: isSubmitting,
                isDisabled: !isFormValid
            ) {
                Task {
                    await submitField()
                }
            }
            .padding(.top, 8)
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func submitField() async {
        guard let acres = Double(acreageInput) else { return }

        isSubmitting = true
        errorMessage = nil

        // Default polygon vertices around Nuwara Eliya agricultural tea centroid
        let baseLat = 6.9642
        let baseLon = 80.7932
        let offset = 0.003
        let polygonCoords: [[[Double]]] = [[
            [baseLon - offset, baseLat - offset],
            [baseLon + offset, baseLat - offset],
            [baseLon + offset, baseLat + offset],
            [baseLon - offset, baseLat + offset],
            [baseLon - offset, baseLat - offset]
        ]]

        let request = FieldCreateRequestDTO(
            estateId: estateId,
            name: fieldName.trimmingCharacters(in: .whitespacesAndNewlines),
            areaAcres: acres,
            boundaryGeojson: GeoJSONPolygonDTO(type: "Polygon", coordinates: polygonCoords)
        )

        do {
            _ = try await apiService.createField(request: request)
            isSubmitting = false
            HapticFeedback.success()
            onCreated()
            dismiss()
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

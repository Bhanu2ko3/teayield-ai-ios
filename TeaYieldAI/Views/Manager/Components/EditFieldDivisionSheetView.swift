import SwiftUI

/// Modal sheet enabling estate managers to update existing tea field division parameters.
struct EditFieldDivisionSheetView: View {

    @Environment(\.dismiss) private var dismiss
    private let field: TeaField
    private let onUpdated: (TeaField) -> Void

    @State private var fieldName: String
    @State private var acreageInput: String
    @State private var selectedStatus: FieldReadinessStatus
    @State private var isSubmitting: Bool = false

    init(
        field: TeaField,
        onUpdated: @escaping (TeaField) -> Void
    ) {
        self.field = field
        self.onUpdated = onUpdated
        _fieldName = State(initialValue: field.name)
        _acreageInput = State(initialValue: String(format: "%.2f", field.acreage))
        _selectedStatus = State(initialValue: field.status)
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
            .navigationTitle("Edit Field Division")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .applyAppTheme()
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "BLOCK PARAMETERS",
                subtitle: "Update boundary designation and physiological harvest phase",
                icon: "slider.horizontal.3"
            )

            // Block Identifier (Readonly tag)
            HStack {
                Text("Block Code")
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(field.blockCode)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.emerald.opacity(0.12))
                    .cornerRadius(AppTheme.radiusSmall)
            }
            .padding(.horizontal, 4)

            // Division Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Division Name")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Upper Ridge Division Block A", text: $fieldName)
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

                    TextField("e.g. 22.50", text: $acreageInput)
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

            // Physiological Crop Status Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Harvest Readiness Status")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                Picker("Readiness Status", selection: $selectedStatus) {
                    ForEach(FieldReadinessStatus.allCases, id: \.self) { status in
                        Text(status.displayName).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            TeaYieldButton(
                title: "Save Changes",
                icon: "checkmark.circle.fill",
                style: .primary,
                isLoading: isSubmitting,
                isDisabled: !isFormValid
            ) {
                saveChanges()
            }
            .padding(.top, 8)
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func saveChanges() {
        guard let acres = Double(acreageInput) else { return }
        isSubmitting = true

        let updatedField = TeaField(
            id: field.id,
            estateId: field.estateId,
            name: fieldName.trimmingCharacters(in: .whitespacesAndNewlines),
            blockCode: field.blockCode,
            acreage: acres,
            currentNDVI: field.currentNDVI,
            status: selectedStatus,
            centroidLatitude: field.centroidLatitude,
            centroidLongitude: field.centroidLongitude,
            polygonCoordinates: field.polygonCoordinates,
            lastHarvestedDate: field.lastHarvestedDate
        )

        onUpdated(updatedField)
        dismiss()
    }
}


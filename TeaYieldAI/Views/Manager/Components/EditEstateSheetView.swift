import SwiftUI

/// Modal sheet enabling estate managers to update operational parameters and factory withering ceilings.
struct EditEstateSheetView: View {

    @Environment(\.dismiss) private var dismiss
    private let apiService: APIServiceProtocol
    private let estateId: UUID
    private let onUpdated: () -> Void

    @State private var estateName: String
    @State private var selectedDistrict: String = SriLankanTeaDistrict.nuwaraEliya.rawValue
    @State private var elevationInput: String = "1850"
    @State private var totalAcresInput: String
    @State private var dailyFactoryCapacityInput: String
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false

    init(
        apiService: APIServiceProtocol,
        estateId: UUID,
        currentName: String,
        currentAcres: Double,
        currentCapacityKg: Double,
        onUpdated: @escaping () -> Void
    ) {
        self.apiService = apiService
        self.estateId = estateId
        self.onUpdated = onUpdated
        _estateName = State(initialValue: currentName)
        _totalAcresInput = State(initialValue: currentAcres > 0 ? String(format: "%.1f", currentAcres) : "")
        _dailyFactoryCapacityInput = State(initialValue: currentCapacityKg > 0 ? String(format: "%.0f", currentCapacityKg) : "")
    }

    private var isFormValid: Bool {
        let nameTrimmed = estateName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameTrimmed.count >= 2 && nameTrimmed.count <= 150 else { return false }
        guard let elev = Int(InputSanitizer.sanitizeInteger(elevationInput)), elev >= 50 && elev <= 2600 else { return false }
        guard let acres = Double(InputSanitizer.sanitizeDecimal(totalAcresInput)), acres >= 1.0 && acres <= 50000.0 else { return false }
        guard let cap = Double(InputSanitizer.sanitizeDecimal(dailyFactoryCapacityInput)), cap >= 100.0 && cap <= 100000.0 else { return false }
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
            .navigationTitle("Edit Estate Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Update Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Could not update estate profile.")
            }
            .applyAppTheme()
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "ESTATE PARAMETERS",
                subtitle: "Update physical boundaries and factory withering ceilings",
                icon: "building.2.crop.circle.fill"
            )

            // Estate Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Estate Designation")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Pedro Estate Nuwara Eliya", text: $estateName)
                        .font(.appBody)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // District Picker
            DistrictPickerField(selectedDistrict: $selectedDistrict)

            // Mean Elevation
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Mean Elevation")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("50 – 2,600 m")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "mountain.2.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 1850", text: $elevationInput)
                        .keyboardType(.numberPad)
                        .onChange(of: elevationInput) { newValue in
                            elevationInput = InputSanitizer.sanitizeInteger(newValue)
                        }

                    Text("m a.s.l.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Total Acreage
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Total Landholding")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0 – 50,000 Ac")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "square.dashed")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 450.0", text: $totalAcresInput)
                        .keyboardType(.decimalPad)
                        .onChange(of: totalAcresInput) { newValue in
                            totalAcresInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("Acres")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Factory Intake Limit
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Daily Factory Withering Limit")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("100 – 100,000 kg")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 12000", text: $dailyFactoryCapacityInput)
                        .keyboardType(.decimalPad)
                        .onChange(of: dailyFactoryCapacityInput) { newValue in
                            dailyFactoryCapacityInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg / day")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            TeaYieldButton(
                title: "Save Estate Configuration",
                icon: "checkmark.circle.fill",
                style: .primary,
                isLoading: isSubmitting,
                isDisabled: !isFormValid
            ) {
                Task {
                    await submitUpdate()
                }
            }
            .padding(.top, 8)
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func submitUpdate() async {
        guard let acres = Double(totalAcresInput),
              let cap = Double(dailyFactoryCapacityInput),
              let elev = Int(elevationInput) else { return }

        isSubmitting = true
        errorMessage = nil

        let request = EstateUpdateRequestDTO(
            name: estateName.trimmingCharacters(in: .whitespacesAndNewlines),
            district: selectedDistrict,
            elevationMeters: elev,
            totalAreaAcres: acres,
            dailyFactoryCapacityKg: cap
        )

        do {
            _ = try await apiService.updateEstate(id: estateId, request: request)
            isSubmitting = false
            HapticFeedback.success()
            onUpdated()
            dismiss()
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

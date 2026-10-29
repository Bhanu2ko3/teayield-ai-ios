import SwiftUI

/// Form interface for field supervisors to record plucker green leaf harvest weights and fine leaf quality.
/// Conforms strictly to Section 5 Design System and authentic estate onboarding styling patterns.
struct HarvestWeighingFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HarvestWeighingViewModel

    init(viewModel: HarvestWeighingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var selectedField: TeaField? {
        viewModel.availableFields.first(where: { $0.id == viewModel.selectedFieldId })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        headerHeroSection
                        fieldAssignmentCard
                        pluckerDetailsCard
                        weightMeasurementCard
                        shootQualityCard
                        geospatialAuditCard

                        if let message = viewModel.validationMessage {
                            validationBanner(message: message)
                        }

                        submitButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Record Leaf Weighing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.appBody)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Dismiss Weighing Form")
                }
            }
            .alert("Weighing Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Failed to save record.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var headerHeroSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "scalemass.fill")
                    .foregroundColor(AppTheme.emerald)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Green Leaf Intake Weigh-In")
                    .font(.appHeadline)
                    .foregroundColor(.primary)

                Text("Record harvest batch weights, tare deduction, and leaf shoot maturity.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var fieldAssignmentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "FIELD ASSIGNMENT",
                subtitle: "Select active plucking block for batch traceability",
                icon: "leaf.fill"
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Target Field Block")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Menu {
                    ForEach(viewModel.availableFields) { field in
                        Button {
                            viewModel.selectedFieldId = field.id
                            viewModel.updateCoordinatesForSelectedField()
                            HapticFeedback.selection()
                        } label: {
                            HStack {
                                Text(field.name)
                                Spacer()
                                Text(field.formattedAcreage)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(selectedField == nil ? .secondary : AppTheme.emerald)
                            .frame(width: 20)

                        if let field = selectedField {
                            Text(field.name)
                                .font(.appBody)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(field.formattedAcreage)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Select Field Block")
                                .font(.appBody)
                                .foregroundColor(.secondary)

                            Spacer()
                        }

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)
                }
                .accessibilityLabel("Target Field Block: \(selectedField?.name ?? "Not selected")")
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var pluckerDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "PLUCKER IDENTIFICATION",
                subtitle: "Assign weigh-in batch to registered estate worker",
                icon: "person.text.rectangle.fill"
            )

            if !viewModel.availablePluckers.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estate Plucker Roster")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Menu {
                        ForEach(viewModel.availablePluckers) { plucker in
                            Button {
                                viewModel.selectPlucker(plucker)
                                HapticFeedback.selection()
                            } label: {
                                HStack {
                                    Text("\(plucker.pluckerCode) - \(plucker.fullName)")
                                    Spacer()
                                    Text(plucker.formattedAverageRate)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(viewModel.selectedPlucker == nil ? .secondary : AppTheme.emerald)
                                .frame(width: 20)

                            if let plucker = viewModel.selectedPlucker {
                                Text("\(plucker.pluckerCode) • \(plucker.fullName)")
                                    .font(.appBody)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text(plucker.formattedAverageRate)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Choose from Estate Roster")
                                    .font(.appBody)
                                    .foregroundColor(.secondary)

                                Spacer()
                            }

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .cornerRadius(AppTheme.radiusMedium)
                    }
                    .accessibilityLabel("Estate Plucker Roster: \(viewModel.selectedPlucker?.displayName ?? "Not selected")")
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("No pluckers registered on estate database. Enter plucker details manually below.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            HStack(spacing: 12) {
                // Plucker ID
                VStack(alignment: .leading, spacing: 6) {
                    Text("Plucker Code")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.secondary)
                            .frame(width: 16)

                        TextField("PLK-001", text: $viewModel.pluckerId)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onChange(of: viewModel.pluckerId) { newValue in
                                viewModel.pluckerId = InputSanitizer.sanitizePluckerId(newValue)
                            }
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)
                }
                .frame(maxWidth: 135)

                // Plucker Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Worker Name")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 16)

                        TextField("Enter name", text: $viewModel.pluckerName)
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)
                }
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var weightMeasurementCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "WEIGHT MEASUREMENT",
                subtitle: "Gross scale reading and container tare weight deduction",
                icon: "scalemass.fill"
            )

            // Gross Weight
            VStack(alignment: .leading, spacing: 6) {
                Text("Gross Scale Reading")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "scalemass")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("0.0", text: $viewModel.grossWeightInput)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .onChange(of: viewModel.grossWeightInput) { newValue in
                            viewModel.grossWeightInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Bag Tare Weight with Presets
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Bag Tare Deduction")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Standard: 1.5 kg")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("1.5", text: $viewModel.bagTareWeightInput)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .onChange(of: viewModel.bagTareWeightInput) { newValue in
                            viewModel.bagTareWeightInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)

                // Tare Presets
                HStack(spacing: 8) {
                    Text("Presets:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    tarePresetChip(title: "1.0 kg", value: 1.0)
                    tarePresetChip(title: "1.5 kg", value: 1.5)
                    tarePresetChip(title: "2.0 kg", value: 2.0)
                }
                .padding(.top, 4)
            }

            // Net Weight Output
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Net Green Leaf Weight")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Audited intake allocated to trough aeration")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(String(format: "%.2f kg", viewModel.netWeight))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }
            .padding(14)
            .background(AppTheme.emerald.opacity(0.08))
            .cornerRadius(AppTheme.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                    .stroke(AppTheme.emerald.opacity(0.22), lineWidth: 1)
            )
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func tarePresetChip(title: String, value: Double) -> some View {
        let isSelected = abs(viewModel.bagTareWeight - value) < 0.05
        return Button {
            viewModel.selectTarePreset(value)
            HapticFeedback.selection()
        } label: {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? AppTheme.emerald : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.emerald.opacity(0.14) : Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusSmall)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusSmall)
                        .stroke(isSelected ? AppTheme.emerald.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var shootQualityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "SHOOT MATURITY ASSESSMENT",
                subtitle: "Two leaves and a bud fine leaf ratio evaluated against auction grade",
                icon: "rosette"
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Fine Leaf Ratio")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(String(format: "%.0f%%", viewModel.fineLeafRatio * 100.0))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)
                }

                Slider(value: $viewModel.fineLeafRatio, in: 0.50...1.0, step: 0.05)
                    .tint(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)

                HStack(spacing: 8) {
                    Image(systemName: viewModel.isQualityExportGrade ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)

                    Text(viewModel.isQualityExportGrade ? "Meets 85% Auction Benchmark (Two Leaves & A Bud)" : "Below 85% - High Coarse Leaf Ratio")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)

                    Spacer()
                }
                .padding(10)
                .background((viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber).opacity(0.10))
                .cornerRadius(AppTheme.radiusMedium)
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var geospatialAuditCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "GEOSPATIAL AUDIT",
                subtitle: "GPS field centroid tag for immutable weigh-in provenance",
                icon: "location.fill"
            )

            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(viewModel.latitude != 0.0 ? AppTheme.emerald : .secondary)
                    .font(.system(size: 14))

                if viewModel.latitude != 0.0 && viewModel.longitude != 0.0 {
                    Text(String(format: "Lat: %.4f • Lon: %.4f", viewModel.latitude, viewModel.longitude))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("CENTROID VERIFIED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppTheme.emerald.opacity(0.12))
                        .cornerRadius(AppTheme.radiusSmall)
                } else {
                    Text("Field Coordinates Pending Selection")
                        .font(.appCaption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
            .padding(14)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .cornerRadius(AppTheme.radiusMedium)
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func validationBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppTheme.crimson)
                .font(.system(size: 14))

            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.crimson)

            Spacer()
        }
        .padding(12)
        .background(AppTheme.crimson.opacity(0.10))
        .cornerRadius(AppTheme.radiusMedium)
    }

    private var submitButtonSection: some View {
        VStack(spacing: 12) {
            TeaYieldButton(
                title: "Save Weighing Record",
                icon: "scalemass.fill",
                style: .primary,
                isLoading: viewModel.isSaving,
                isDisabled: !viewModel.isFormValid
            ) {
                Task {
                    let success = await viewModel.saveWeighingRecord()
                    if success {
                        HapticFeedback.success()
                        dismiss()
                    } else {
                        HapticFeedback.error()
                    }
                }
            }

            Button {
                dismiss()
            } label: {
                Text("Discard Entry")
                    .font(.appCallout)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

// MARK: - Previews

struct HarvestWeighingFormView_Previews: PreviewProvider {
    static var previews: some View {
        HarvestWeighingFormView(
            viewModel: HarvestWeighingViewModel(
                harvestRepository: AppContainer.shared.harvestRepository,
                fieldRepository: AppContainer.shared.fieldRepository,
                syncManager: AppContainer.shared.syncManager,
                authService: AppContainer.shared.authService,
                apiService: AppContainer.shared.apiService
            )
        )
    }
}

import SwiftUI

/// Form interface for field supervisors to record plucker green leaf harvest weights and fine leaf quality.
struct HarvestWeighingFormView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HarvestWeighingViewModel

    init(viewModel: HarvestWeighingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                fieldSelectionSection
                pluckerIdentitySection
                weightMeasurementSection
                leafQualitySection
                locationVerificationSection

                if let message = viewModel.validationMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(message)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Record Leaf Weighing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Weighing Form")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let success = await viewModel.saveWeighingRecord()
                            if success {
                                HapticFeedback.success()
                                dismiss()
                            } else {
                                HapticFeedback.error()
                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(viewModel.isSaving)
                    .accessibilityLabel("Save Weighing Record")
                    .accessibilityHint("Validates measurements and saves harvest log into offline repository")
                }
            }
            .alert("Weighing Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Failed to save record.")
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .applyAppTheme()
    }

    // MARK: - Sections

    private var fieldSelectionSection: some View {
        Section(header: Text("Field Assignment")) {
            Picker("Target Field", selection: $viewModel.selectedFieldId) {
                Text("Select Field").tag(nil as UUID?)
                ForEach(viewModel.availableFields) { field in
                    Text("\(field.name) (\(field.formattedAcreage))")
                        .tag(field.id as UUID?)
                }
            }
            .onChange(of: viewModel.selectedFieldId) { _ in
                viewModel.updateCoordinatesForSelectedField()
            }
        }
    }

    private var pluckerIdentitySection: some View {
        Section(header: Text("Plucker Details")) {
            if !viewModel.availablePluckers.isEmpty {
                Picker("Registered Plucker", selection: Binding(
                    get: { viewModel.selectedPlucker },
                    set: { plucker in
                        if let plucker = plucker {
                            viewModel.selectPlucker(plucker)
                        }
                    }
                )) {
                    Text("Select from estate roster").tag(nil as Plucker?)
                    ForEach(viewModel.availablePluckers) { plucker in
                        Text("\(plucker.displayName) (\(plucker.formattedAverageRate))")
                            .tag(plucker as Plucker?)
                    }
                }
            }

            HStack {
                Text("Plucker ID")
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)

                TextField("Enter plucker ID", text: $viewModel.pluckerId)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.pluckerId) { newValue in
                        viewModel.pluckerId = InputSanitizer.sanitizePluckerId(newValue)
                    }
            }

            HStack {
                Text("Name")
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)

                TextField("Enter plucker name", text: $viewModel.pluckerName)
                    .autocapitalization(.words)
                    .disableAutocorrection(false)
            }
        }
    }

    private var weightMeasurementSection: some View {
        Section(header: Text("Weight Measurement")) {
            HStack {
                Text("Gross Weight")
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)

                TextField("Enter gross weight", text: $viewModel.grossWeightInput)
                    .keyboardType(.decimalPad)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.grossWeightInput) { newValue in
                        viewModel.grossWeightInput = InputSanitizer.sanitizeDecimal(newValue)
                    }

                Text("kg")
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Bag Tare")
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)

                    TextField("Enter tare weight", text: $viewModel.bagTareWeightInput)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.bagTareWeightInput) { newValue in
                            viewModel.bagTareWeightInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg")
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Text("Presets:")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Button("1.0 kg") { viewModel.selectTarePreset(1.0) }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)

                    Button("1.5 kg") { viewModel.selectTarePreset(1.5) }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)

                    Button("2.0 kg") { viewModel.selectTarePreset(2.0) }
                        .buttonStyle(.bordered)
                        .controlSize(.mini)
                }
            }

            HStack {
                Text("Net Weight")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(String(format: "%.2f kg", viewModel.netWeight))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }
            .padding(.vertical, 4)
        }
    }

    private var leafQualitySection: some View {
        Section(header: Text("Shoot Quality Assessment")) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fine Leaf Ratio")
                        .font(.subheadline)

                    Spacer()

                    Text(String(format: "%.0f%%", viewModel.fineLeafRatio * 100.0))
                        .font(.headline)
                        .foregroundColor(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)
                }

                Slider(value: $viewModel.fineLeafRatio, in: 0.50...1.0, step: 0.05)
                    .tint(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)

                HStack(spacing: 6) {
                    Image(systemName: viewModel.isQualityExportGrade ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(viewModel.isQualityExportGrade ? "Meets 85% Auction Benchmark (Two Leaves & A Bud)" : "Below 85% - High Coarse Leaf Ratio")
                        .font(.caption)
                }
                .foregroundColor(viewModel.isQualityExportGrade ? AppTheme.emerald : AppTheme.amber)
            }
            .padding(.vertical, 4)
        }
    }

    private var locationVerificationSection: some View {
        Section(header: Text("Geospatial Coordinates")) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)

                if viewModel.latitude != 0.0 && viewModel.longitude != 0.0 {
                    Text(String(format: "Lat: %.4f, Lon: %.4f", viewModel.latitude, viewModel.longitude))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Centroid Verified")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.emerald.opacity(0.12))
                        .foregroundColor(AppTheme.emerald)
                        .cornerRadius(AppTheme.radiusSmall)
                } else {
                    Text("Field Coordinates Pending Selection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
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



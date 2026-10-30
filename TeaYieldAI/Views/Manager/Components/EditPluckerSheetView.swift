import SwiftUI

/// Modal sheet enabling estate managers to edit existing plucker details and daily plucking quota.
struct EditPluckerSheetView: View {

    @Environment(\.dismiss) private var dismiss
    private let apiService: APIServiceProtocol
    private let plucker: Plucker
    private let onUpdated: () -> Void

    @State private var fullName: String
    @State private var dailyRateInput: String
    @State private var isActive: Bool
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false

    init(
        apiService: APIServiceProtocol,
        plucker: Plucker,
        onUpdated: @escaping () -> Void
    ) {
        self.apiService = apiService
        self.plucker = plucker
        self.onUpdated = onUpdated
        _fullName = State(initialValue: plucker.fullName)
        _dailyRateInput = State(initialValue: String(format: "%.1f", plucker.averageDailyRateKg))
        _isActive = State(initialValue: plucker.isActive)
    }

    private var isFormValid: Bool {
        let nameTrimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameTrimmed.count >= 2 && nameTrimmed.count <= 100 else { return false }
        guard let rate = Double(InputSanitizer.sanitizeDecimal(dailyRateInput)), rate >= 5.0 && rate <= 150.0 else { return false }
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
            .navigationTitle("Edit Plucker Profile")
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
                Text(errorMessage ?? "Could not update plucker profile on estate database.")
            }
            .applyAppTheme()
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "WORKFORCE RECORD",
                subtitle: "Update worker productivity metrics and active plucking duty",
                icon: "person.badge.shield.checkmark.fill"
            )

            // Badge Code (Read-Only)
            VStack(alignment: .leading, spacing: 6) {
                Text("Badge / Employee Code (Immutable)")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    Text(plucker.pluckerCode)
                        .font(.appBody)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.6))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Full Legal Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Legal Name")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Full legal name", text: $fullName)
                        .font(.appBody)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Daily Plucking Rate
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Baseline Daily Harvest Rate")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("5.0 – 150.0 kg")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "scalemass.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Daily rate", text: $dailyRateInput)
                        .keyboardType(.decimalPad)
                        .onChange(of: dailyRateInput) { newValue in
                            dailyRateInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg / day")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Active Duty Toggle
            Toggle(isOn: $isActive) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active Plucking Duty")
                        .font(.appBody)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("Enrolled in weekly Genetic Algorithm harvest rosters")
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(AppTheme.emerald)
            .padding(14)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .cornerRadius(AppTheme.radiusMedium)

            TeaYieldButton(
                title: "Save Profile Changes",
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
        guard let rate = Double(dailyRateInput) else { return }

        isSubmitting = true
        errorMessage = nil

        let request = PluckerUpdateRequestDTO(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            averageDailyRateKg: rate,
            isActive: isActive
        )

        do {
            _ = try await apiService.updatePlucker(id: plucker.id, request: request)
            isSubmitting = false
            HapticFeedback.success()
            onUpdated()
            dismiss()
        } catch let networkError as NetworkError {
            isSubmitting = false
            errorMessage = networkError.localizedDescription
            showErrorAlert = true
            HapticFeedback.warning()
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            showErrorAlert = true
            HapticFeedback.warning()
        }
    }
}

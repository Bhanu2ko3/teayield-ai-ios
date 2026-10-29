import SwiftUI

/// Modal sheet enabling estate managers to enroll a new tea plucker into the estate labor roster.
struct AddPluckerSheetView: View {

    @Environment(\.dismiss) private var dismiss
    private let apiService: APIServiceProtocol
    private let estateId: UUID
    private let onCreated: () -> Void

    @State private var pluckerCode: String = ""
    @State private var fullName: String = ""
    @State private var dailyRateInput: String = "25.0"
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
        let codeTrimmed = pluckerCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameTrimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard codeTrimmed.count >= 2 && codeTrimmed.count <= 30 else { return false }
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
            .navigationTitle("Enroll New Plucker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Enrollment Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Could not register plucker on the estate database.")
            }
            .applyAppTheme()
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(
                title: "PLUCKER INFORMATION",
                subtitle: "Assign identification badge and historical harvesting productivity",
                icon: "person.badge.plus.fill"
            )

            // Plucker Code
            VStack(alignment: .leading, spacing: 6) {
                Text("Badge / Employee Code")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. PLK-106", text: $pluckerCode)
                        .font(.appBody)
                        .autocapitalization(.allCharacters)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Full Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Legal Name")
                    .font(.appCaption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Kamala Selvam", text: $fullName)
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

                    TextField("e.g. 25.0", text: $dailyRateInput)
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

            TeaYieldButton(
                title: "Enroll Plucker Worker",
                icon: "plus.circle.fill",
                style: .primary,
                isLoading: isSubmitting,
                isDisabled: !isFormValid
            ) {
                Task {
                    await submitPlucker()
                }
            }
            .padding(.top, 8)
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func submitPlucker() async {
        guard let rate = Double(dailyRateInput) else { return }

        isSubmitting = true
        errorMessage = nil

        let request = PluckerCreateRequestDTO(
            estateId: estateId,
            pluckerCode: pluckerCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            averageDailyRateKg: rate,
            isActive: true
        )

        do {
            _ = try await apiService.createPlucker(request: request)
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

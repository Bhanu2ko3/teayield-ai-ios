import SwiftUI

/// Onboarding wizard capturing mandatory agro-ecological priors and physical factory limits
/// required by the cloud LSTM yield predictor and Genetic Algorithm before unlocking dashboard access.
struct EstateOnboardingView: View {

    @StateObject private var viewModel: EstateOnboardingViewModel

    init(authService: AuthServiceProtocol, apiService: APIServiceProtocol) {
        _viewModel = StateObject(wrappedValue: EstateOnboardingViewModel(
            authService: authService,
            apiService: apiService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topHeaderBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                        .background(Color(uiColor: .systemGroupedBackground))

                    ScrollView {
                        VStack(spacing: 20) {
                            headerSection
                            priorExplanationBanner
                            formFieldsCard
                            submitButtonSection
                            cancelSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Estate Setup Incomplete", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Please review all entered parameters.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var topHeaderBar: some View {
        HStack {
            Text("Estate Setup")
                .font(.appHeadline)
                .foregroundColor(.secondary)

            Spacer()

            ThemeToggleView(style: .circle)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: "building.columns.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(AppTheme.emerald)
            }
            .padding(.top, 4)

            Text("Register Tea Estate")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Enter plantation division details and factory capacity limits to calibrate yield forecasting and harvesting rosters.")
                .font(.appSubheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    private var priorExplanationBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(AppTheme.emerald)
                .font(.system(size: 18))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Operational Calibration")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Elevation calibrates vegetative growth cycles and weather patterns, while factory capacity ensures daily plucking rosters stay within safe withering limits.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.emerald.opacity(0.08))
        .cornerRadius(AppTheme.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .stroke(AppTheme.emerald.opacity(0.20), lineWidth: 1)
        )
    }

    private var formFieldsCard: some View {
        VStack(spacing: 16) {
            // Estate Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Estate Name")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Radella Estate", text: $viewModel.estateName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // District Picker
            DistrictPickerField(selectedDistrict: $viewModel.selectedDistrict)

            // Mean Elevation
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Mean Elevation")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Range: 50 – 2,600 m")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "mountain.2.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 1850", text: $viewModel.elevationInput)
                        .keyboardType(.numberPad)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.elevationInput) { newValue in
                            viewModel.elevationInput = InputSanitizer.sanitizeInteger(newValue)
                        }

                    Text("m a.s.l.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)

                if !viewModel.elevationInput.isEmpty && !viewModel.isElevationValid {
                    Text("Elevation must be between 50m and 2,600m above sea level.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.crimson)
                }
            }

            // Total Acreage
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Total Landholding")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Range: 1.0 – 50,000.0")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "square.dashed")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 450.0", text: $viewModel.totalAcresInput)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.totalAcresInput) { newValue in
                            viewModel.totalAcresInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("Acres")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)

                if !viewModel.totalAcresInput.isEmpty && !viewModel.isAcresValid {
                    Text("Acreage must be between 1.0 and 50,000.0 acres.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.crimson)
                }
            }

            // Factory Intake Capacity
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Daily Factory Intake Limit")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Max Withering Cap")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. 25000", text: $viewModel.dailyFactoryCapacityInput)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.dailyFactoryCapacityInput) { newValue in
                            viewModel.dailyFactoryCapacityInput = InputSanitizer.sanitizeDecimal(newValue)
                        }

                    Text("kg / day")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)

                if !viewModel.dailyFactoryCapacityInput.isEmpty && !viewModel.isCapacityValid {
                    Text("Daily factory intake capacity must be between 1.0 and 200,000 kg.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.crimson)
                }
            }
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var submitButtonSection: some View {
        TeaYieldButton(
            title: "Register Estate & Continue",
            icon: "arrow.right",
            style: .primary,
            isLoading: viewModel.isSubmitting,
            isDisabled: !viewModel.isFormValid,
            action: {
                Task {
                    await viewModel.onboardEstate()
                }
            }
        )
    }

    private var cancelSection: some View {
        Button {
            viewModel.cancelAndLogout()
        } label: {
            Text("Sign out and return to login")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
        .accessibilityLabel("Sign out")
        .accessibilityHint("Logs out of current account and returns to login screen")
    }
}

// MARK: - Previews

struct EstateOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        EstateOnboardingView(
            authService: AppContainer.shared.authService,
            apiService: AppContainer.shared.apiService
        )
    }
}



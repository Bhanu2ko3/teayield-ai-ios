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

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        priorExplanationBanner
                        formFieldsCard
                        submitButtonSection
                        cancelSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Estate Setup")
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                }
            }
            .alert("Onboarding Incomplete", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Please review all entered parameters.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

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
            .padding(.top, 8)

            Text("Register Plantation Estate")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Configure your commercial plantation parameters to initialize AI yield forecasting and genetic plucking rosters.")
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
                Text("Mathematical Priors for AI Engines")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Elevation calibrates Sentinel-2 atmospheric lapse rates and NDVI decay. Factory withering capacity acts as the hard ceiling constraint in the genetic plucking scheduler.")
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
                Text("Commercial Estate Name")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("e.g. Great Western Valley Estate", text: $viewModel.estateName)
                        .autocapitalization(.words)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // District Picker
            DistrictPickerField(selectedDistrict: $viewModel.selectedDistrict) { district in
                viewModel.applyDistrictDefaults(district)
            }

            // Mean Elevation
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Mean Elevation (Meters)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Valid: 50m - 2,600m")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "mountain.2.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Elevation in meters", text: $viewModel.elevationInput)
                        .keyboardType(.numberPad)

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
                    Text("Total Surveyed Landholding (Acres)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("1.0 - 50,000.0 acres")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "square.dashed")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Total acres", text: $viewModel.totalAcresInput)
                        .keyboardType(.decimalPad)

                    Text("Acres")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Factory Intake Capacity
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Daily Factory Capacity (Kg/Day)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Withering Troughs Limit")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "shippingbox.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Max kg per day", text: $viewModel.dailyFactoryCapacityInput)
                        .keyboardType(.decimalPad)

                    Text("kg / day")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var submitButtonSection: some View {
        TeaYieldButton(
            title: "Complete Estate Onboarding",
            icon: "checkmark.shield.fill",
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



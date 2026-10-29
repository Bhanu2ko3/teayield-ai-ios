import SwiftUI

/// Mandatory credential rotation screen presented when `mustChangePassword == true`.
/// Prevents access to operational field data until the temporary manager-issued password is replaced.
struct ForcePasswordChangeView: View {

    @StateObject private var viewModel: ForcePasswordChangeViewModel
    @State private var isCurrentPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    init(authService: AuthServiceProtocol, apiService: APIServiceProtocol) {
        _viewModel = StateObject(wrappedValue: ForcePasswordChangeViewModel(
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
                            securityHeaderSection
                            securityNoticeBanner
                            passwordFieldsCard
                            requirementsCard
                            actionButtonSection
                            logoutSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Password Update Failed", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred while updating your credentials.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var topHeaderBar: some View {
        HStack {
            Text("Security Verification")
                .font(.appHeadline)
                .foregroundColor(.secondary)

            Spacer()

            ThemeToggleView(style: .circle)
        }
    }

    private var securityHeaderSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppTheme.amber.opacity(0.14))
                    .frame(width: 64, height: 64)

                Image(systemName: "lock.rotation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(AppTheme.amber)
            }
            .padding(.top, 8)

            Text("Set Permanent Password")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Your account was created with a temporary password. Choose a secure personal password to access your field operations.")
                .font(.appSubheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    private var securityNoticeBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(AppTheme.amber)
                .font(.system(size: 18))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("First-Time Security Policy")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Temporary passwords must be updated on first sign-in to protect plucking checklists and green leaf weighing records.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.amber.opacity(0.08))
        .cornerRadius(AppTheme.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .stroke(AppTheme.amber.opacity(0.20), lineWidth: 1)
        )
    }

    private var passwordFieldsCard: some View {
        VStack(spacing: 16) {
            // Current Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Temporary Password")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    if isCurrentPasswordVisible {
                        TextField("Enter temporary password", text: $viewModel.currentPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Enter temporary password", text: $viewModel.currentPassword)
                    }

                    Button {
                        isCurrentPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isCurrentPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .accessibilityLabel(isCurrentPasswordVisible ? "Hide current password" : "Show current password")
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // New Password
            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    if isNewPasswordVisible {
                        TextField("Enter new password", text: $viewModel.newPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Enter new password", text: $viewModel.newPassword)
                    }

                    Button {
                        isNewPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isNewPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .accessibilityLabel(isNewPasswordVisible ? "Hide new password" : "Show new password")
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    if isConfirmPasswordVisible {
                        TextField("Re-enter new password", text: $viewModel.confirmPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Re-enter new password", text: $viewModel.confirmPassword)
                    }

                    Button {
                        isConfirmPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .accessibilityLabel(isConfirmPasswordVisible ? "Hide confirm password" : "Show confirm password")
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(AppTheme.radiusMedium)
            }
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var requirementsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password Requirements")
                .font(.appCaption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            requirementRow(
                isSatisfied: viewModel.hasMinimumLength,
                text: "At least 8 characters long"
            )

            requirementRow(
                isSatisfied: viewModel.isDifferentFromCurrent,
                text: "Different from temporary password"
            )

            requirementRow(
                isSatisfied: viewModel.passwordsMatch,
                text: "Both passwords match exactly"
            )
        }
        .padding(14)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    private func requirementRow(isSatisfied: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isSatisfied ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSatisfied ? AppTheme.emerald : .secondary.opacity(0.5))
                .font(.system(size: 13))

            Text(text)
                .font(.system(size: 12, weight: isSatisfied ? .medium : .regular))
                .foregroundColor(isSatisfied ? .primary : .secondary)

            Spacer()
        }
    }

    private var actionButtonSection: some View {
        TeaYieldButton(
            title: "Update Password & Continue",
            icon: "checkmark.shield.fill",
            style: .primary,
            isLoading: viewModel.isSubmitting,
            isDisabled: !viewModel.isFormValid,
            action: {
                Task {
                    await viewModel.changePassword()
                }
            }
        )
    }

    private var logoutSection: some View {
        Button {
            viewModel.logout()
        } label: {
            Text("Sign out and return to login")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
        .accessibilityLabel("Sign out")
    }
}

// MARK: - Previews

struct ForcePasswordChangeView_Previews: PreviewProvider {
    static var previews: some View {
        ForcePasswordChangeView(
            authService: AppContainer.shared.authService,
            apiService: AppContainer.shared.apiService
        )
    }
}



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
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Security Verification")
                        .font(.appHeadline)
                        .foregroundColor(.primary)
                }
            }
            .alert("Password Update Failed", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred while updating your credentials.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

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

            Text("Password Rotation Required")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Your account was provisioned with a manager-issued temporary password. Please establish a private permanent password to access field operations.")
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
                Text("Enterprise Tenant Security Policy")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text("All supervisor accounts require cryptographic password rotation on first sign-in to protect harvest telemetry and field weighing logs.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.amber.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.amber.opacity(0.20), lineWidth: 1)
        )
    }

    private var passwordFieldsCard: some View {
        VStack(spacing: 16) {
            // Current Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Temporary Password")
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
                .cornerRadius(12)
            }

            // New Password
            VStack(alignment: .leading, spacing: 6) {
                Text("New Permanent Password")
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
                            .textContentType(.newPassword)
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
                .cornerRadius(12)
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm New Password")
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
                            .textContentType(.newPassword)
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
                .cornerRadius(12)
            }
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var requirementsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password Criteria")
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
        Button {
            Task {
                await viewModel.changePassword()
            }
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                Text(viewModel.isSubmitting ? "Updating Password..." : "Update Password & Unlock")
                    .font(.appHeadline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(viewModel.isFormValid ? AppTheme.emerald : AppTheme.emerald.opacity(0.4))
            .cornerRadius(14)
        }
        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        .accessibilityLabel("Update Password and Unlock")
        .accessibilityHint("Rotates temporary credentials and opens supervisor workspace")
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

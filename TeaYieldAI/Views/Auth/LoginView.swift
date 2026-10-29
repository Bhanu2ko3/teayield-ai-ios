import SwiftUI

/// Authentication view providing email/password credential input, password visibility toggle,
/// inline validation error feedback, and biometric Face ID access.
struct LoginView: View {

    @StateObject private var viewModel: AuthViewModel
    @State private var isPasswordVisible: Bool = false
    @State private var selectedDemoRole: UserRole? = nil
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var currentThemeMode: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        topAppearanceBar
                        headerSection
                        authModeSegmentedPicker
                        
                        if viewModel.authMode == .signIn {
                            quickRoleSelectorSection
                        }
                        
                        credentialFormSection
                        actionButtonsSection
                        securityFooterSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarHidden(true)
            .alert(viewModel.authMode == .signIn ? "Authentication Failed" : "Registration Failed", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Subviews

    private var authModeSegmentedPicker: some View {
        Picker("Authentication Mode", selection: $viewModel.authMode) {
            ForEach(AuthViewModel.AuthMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Select Sign In or Register Manager mode")
    }

    private var topAppearanceBar: some View {
        HStack {
            Spacer()
            Menu {
                ForEach(AppThemeMode.allCases) { mode in
                    Button {
                        HapticFeedback.selection()
                        appThemeMode = mode.rawValue
                    } label: {
                        Label(mode.title, systemImage: mode.iconName)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: currentThemeMode.iconName)
                    Text(currentThemeMode.shortTitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundColor(AppTheme.emerald)
                .cornerRadius(AppTheme.radiusPill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusPill)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
            }
            .accessibilityLabel("Appearance Theme Switcher: currently \(currentThemeMode.title)")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(AppTheme.emerald)
                .padding(18)
                .background(AppTheme.emerald.opacity(0.12))
                .clipShape(Circle())

            Text("TeaYield AI")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Precision Tea Yield & Harvest Intelligence")
                .font(.appSubheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    /// Fast enterprise profile switcher for evaluation and test demonstrations.
    private var quickRoleSelectorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Enterprise Demo Profiles")
                    .font(.appCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Tap to autofill")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }

            HStack(spacing: 10) {
                demoRoleChip(
                    title: "Field Supervisor",
                    role: .fieldSupervisor,
                    systemImage: "person.badge.shield.checkmark.fill"
                )

                demoRoleChip(
                    title: "Estate Manager",
                    role: .estateManager,
                    systemImage: "briefcase.fill"
                )
            }
        }
    }

    private func demoRoleChip(title: String, role: UserRole, systemImage: String) -> some View {
        let isSelected = selectedDemoRole == role

        return Button {
            selectedDemoRole = role
            viewModel.selectDemoProfile(role: role)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : AppTheme.emerald)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppTheme.emerald : AppTheme.emerald.opacity(0.10))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? AppTheme.emerald : AppTheme.emerald.opacity(0.25), lineWidth: 1)
            )
        }
        .accessibilityLabel("Select \(title) demo account")
    }

    private var credentialFormSection: some View {
        VStack(spacing: 16) {
            if viewModel.authMode == .signUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Legal Name")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("Enter manager full name", text: $viewModel.signUpFullName)
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.authMode == .signUp ? "Corporate Business Email" : "Enterprise Email")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField(viewModel.authMode == .signUp ? "e.g. manager@plantation.lk" : "Enter your enterprise email", text: $viewModel.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)

                    if !viewModel.email.isEmpty {
                        Button {
                            viewModel.email = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .accessibilityLabel("Clear email field")
                    }
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(12)
            }

            if viewModel.authMode == .signUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mobile Contact (Optional)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("e.g. +94 77 123 4567", text: $viewModel.signUpPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.authMode == .signUp ? "Account Password (min 8 characters)" : "Password")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    if isPasswordVisible {
                        TextField(viewModel.authMode == .signUp ? "Create secure password" : "Enter your password", text: $viewModel.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField(viewModel.authMode == .signUp ? "Create secure password" : "Enter your password", text: $viewModel.password)
                            .textContentType(viewModel.authMode == .signUp ? .newPassword : .password)
                    }

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15))
                            .frame(width: 24, height: 24)
                    }
                    .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                }
                .padding(14)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(12)

                if viewModel.authMode == .signUp {
                    Text("Minimum 8 characters required for cryptographic tenant isolation.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }

            // Inline error alert banner if authentication fails
            if let error = viewModel.errorMessage, !error.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14))

                    Text(error)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(10)
                .background(Color.red.opacity(0.08))
                .cornerRadius(8)
            }
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.submit()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(submitButtonTitle)
                        .font(.appHeadline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.emerald)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            .accessibilityLabel(submitButtonTitle)
            .accessibilityHint(viewModel.authMode == .signUp ? "Registers new estate manager tenant account" : "Authenticates credentials with estate server")

            if viewModel.authMode == .signIn && viewModel.isBiometricAvailable {
                Button {
                    Task {
                        await viewModel.authenticateWithBiometrics()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.biometricType == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 18))

                        Text("Sign in with \(viewModel.biometricType.rawValue)")
                            .font(.appSubheadline)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(viewModel.hasEnrolledBiometricCredentials ? "READY" : "LINK ON SIGN-IN")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.emerald.opacity(0.18))
                            .foregroundColor(AppTheme.emerald)
                            .cornerRadius(4)
                    }
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.emerald.opacity(0.10))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .accessibilityLabel("Sign in with \(viewModel.biometricType.rawValue)")
                .accessibilityHint("Authenticates using device Secure Enclave biometric scan")
            }
        }
    }

    private var submitButtonTitle: String {
        if viewModel.isLoading {
            return viewModel.authMode == .signUp ? "Registering Account..." : "Signing In..."
        }
        return viewModel.authMode == .signUp ? "Create Manager Account" : "Sign In"
    }

    private var securityFooterSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text("Protected by 256-bit AES encryption & Biometric Key Store")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
    }
}

import SwiftUI

/// Authentication view providing email/password credential input, password visibility toggle,
/// inline validation error feedback, and biometric Face ID access.
struct LoginView: View {

    @StateObject private var viewModel: AuthViewModel
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case fullName
        case email
        case phone
        case password
        case confirmPassword
    }

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                            authModeSegmentedPicker
                            credentialFormSection

                            if viewModel.authMode == .signUp {
                                requirementsCard
                            }

                            actionButtonsSection
                            securityFooterSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.interactively)
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

    private var topHeaderBar: some View {
        HStack {
            Text(viewModel.authMode == .signUp ? "Manager Registration" : "Sign In")
                .font(.appHeadline)
                .foregroundColor(.secondary)
                .animation(.easeInOut(duration: 0.2), value: viewModel.authMode)

            Spacer()

            ThemeToggleView(style: .circle)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(AppTheme.emerald)
                .padding(18)
                .background(AppTheme.emerald.opacity(0.12))
                .clipShape(Circle())

            Text("TeaYield AI")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Precision Agriculture Ceylon Tea")
                .font(.appSubheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var authModeSegmentedPicker: some View {
        Picker("Authentication Mode", selection: $viewModel.authMode) {
            ForEach(AuthViewModel.AuthMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Select Sign In or Register Manager mode")
        .onChange(of: viewModel.authMode) { _ in
            HapticFeedback.selection()
            viewModel.errorMessage = nil
            viewModel.showErrorAlert = false
        }
    }

    private var credentialFormSection: some View {
        VStack(spacing: 16) {
            if viewModel.authMode == .signUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Name")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("Enter manager full name", text: $viewModel.signUpFullName)
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                            .onChange(of: viewModel.signUpFullName) { _ in
                                if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                            }
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)

                    if !viewModel.signUpFullName.isEmpty && viewModel.signUpFullName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
                        Text("Name must contain at least 2 characters.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.crimson)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.authMode == .signUp ? "Work Email" : "Enterprise Email")
                    .font(.appCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("Enter your email address", text: $viewModel.email)
                        .focused($focusedField, equals: .email)
                        .submitLabel(viewModel.authMode == .signUp ? .next : .next)
                        .onSubmit {
                            if viewModel.authMode == .signUp {
                                focusedField = .phone
                            } else {
                                focusedField = .password
                            }
                        }
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .onChange(of: viewModel.email) { _ in
                            if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                        }

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
                .cornerRadius(AppTheme.radiusMedium)

                if !viewModel.email.isEmpty && !InputSanitizer.isValidEmail(viewModel.email) {
                    Text("Please enter a valid email address.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.crimson)
                }
            }

            if viewModel.authMode == .signUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mobile Phone (Optional)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        HStack(spacing: 6) {
                            Text("+94")
                                .font(.appBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Rectangle()
                                .fill(Color.primary.opacity(0.15))
                                .frame(width: 1, height: 18)
                        }

                        TextField("77 123 4567", text: $viewModel.signUpPhoneNumber)
                            .focused($focusedField, equals: .phone)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .keyboardType(.numberPad)
                            .disableAutocorrection(true)
                            .onChange(of: viewModel.signUpPhoneNumber) { newValue in
                                viewModel.signUpPhoneNumber = InputSanitizer.sanitizeInteger(newValue)
                                if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                            }
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)

                    if !viewModel.signUpPhoneNumber.isEmpty && !viewModel.isSignUpPhoneValid {
                        Text("Enter a valid 9-digit Sri Lankan mobile number.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.crimson)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(viewModel.authMode == .signUp ? "Create Password" : "Password")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(viewModel.authMode == .signUp ? "Min. 8 characters" : "Min. 6 characters")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    if isPasswordVisible {
                        TextField(viewModel.authMode == .signUp ? "Enter secure password" : "Enter password", text: $viewModel.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(viewModel.authMode == .signUp ? .next : .go)
                            .onSubmit {
                                if viewModel.authMode == .signUp {
                                    focusedField = .confirmPassword
                                } else if viewModel.isFormValid {
                                    Task { await viewModel.submit() }
                                }
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: viewModel.password) { _ in
                                if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                            }
                    } else {
                        SecureField(viewModel.authMode == .signUp ? "Enter secure password" : "Enter password", text: $viewModel.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(viewModel.authMode == .signUp ? .next : .go)
                            .onSubmit {
                                if viewModel.authMode == .signUp {
                                    focusedField = .confirmPassword
                                } else if viewModel.isFormValid {
                                    Task { await viewModel.submit() }
                                }
                            }
                            .onChange(of: viewModel.password) { _ in
                                if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                            }
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
                .cornerRadius(AppTheme.radiusMedium)
            }

            if viewModel.authMode == .signUp {
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
                            TextField("Re-enter new password", text: $viewModel.signUpConfirmPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit {
                                    if viewModel.isFormValid {
                                        Task { await viewModel.submit() }
                                    }
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: viewModel.signUpConfirmPassword) { _ in
                                    if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                                }
                        } else {
                            SecureField("Re-enter new password", text: $viewModel.signUpConfirmPassword)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit {
                                    if viewModel.isFormValid {
                                        Task { await viewModel.submit() }
                                    }
                                }
                                .onChange(of: viewModel.signUpConfirmPassword) { _ in
                                    if viewModel.errorMessage != nil { viewModel.errorMessage = nil }
                                }
                        }

                        Button {
                            isConfirmPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15))
                                .frame(width: 24, height: 24)
                        }
                        .accessibilityLabel(isConfirmPasswordVisible ? "Hide confirm password" : "Show confirm password")
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(AppTheme.radiusMedium)
                }
            }

            // Inline error alert banner if authentication fails
            if let error = viewModel.errorMessage, !error.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.crimson)
                        .font(.system(size: 14))

                    Text(error)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.crimson)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(10)
                .background(AppTheme.crimson.opacity(0.08))
                .cornerRadius(AppTheme.radiusSmall)
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
                isSatisfied: viewModel.hasSignUpMinLength,
                text: "At least 8 characters long"
            )

            requirementRow(
                isSatisfied: viewModel.hasSignUpNumber,
                text: "Contains at least one number"
            )

            requirementRow(
                isSatisfied: viewModel.doSignUpPasswordsMatch,
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

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            TeaYieldButton(
                title: submitButtonTitle,
                icon: viewModel.authMode == .signUp ? "person.crop.circle.badge.plus" : "lock.open.fill",
                style: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid,
                action: {
                    Task {
                        await viewModel.submit()
                    }
                }
            )

            if viewModel.authMode == .signIn && viewModel.isBiometricAvailable {
                TeaYieldButton(
                    title: "Sign in with \(viewModel.biometricType.rawValue)",
                    icon: viewModel.biometricType == .faceID ? "faceid" : "touchid",
                    style: .tonal,
                    isLoading: false,
                    isDisabled: viewModel.isLoading,
                    action: {
                        Task {
                            await viewModel.authenticateWithBiometrics()
                        }
                    }
                )
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
            Text("Secured by iOS Keychain & Biometric Authentication")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: AuthViewModel(authService: AppContainer.shared.authService))
    }
}


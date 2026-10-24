import SwiftUI

/// Authentication view providing email/password credential input and biometric Face ID access.
struct LoginView: View {

    @StateObject private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        credentialFormSection
                        actionButtonsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
            .navigationBarHidden(true)
            .alert("Authentication Failed", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected authentication error occurred.")
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
                .padding(18)
                .background(Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.12))
                .clipShape(Circle())

            Text("TeaYield AI")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Precision Tea Yield & Harvest Intelligence")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private var credentialFormSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    TextField("supervisor@teayield.ai", text: $viewModel.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                        .frame(width: 20)

                    SecureField("Enter your password", text: $viewModel.password)
                        .textContentType(.password)
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 14) {
            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(viewModel.isLoading ? "Signing In..." : "Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.02, green: 0.59, blue: 0.41))
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)

            if viewModel.isBiometricAvailable {
                Button {
                    Task {
                        await viewModel.authenticateWithBiometrics()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.biometricType == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 20))
                        Text("Sign in with \(viewModel.biometricType.rawValue)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.1))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

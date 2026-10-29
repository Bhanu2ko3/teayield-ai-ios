import SwiftUI

/// Modal sheet enabling estate managers to provision subordinate field supervisors.
/// Generates temporary passwords and provides instant credential copying for field dispatch.
struct InviteSupervisorSheetView: View {

    @StateObject private var viewModel: InviteSupervisorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var hasCopiedCredentials: Bool = false

    init(apiService: APIServiceProtocol) {
        _viewModel = StateObject(wrappedValue: InviteSupervisorViewModel(apiService: apiService))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.invitationSuccess {
                            invitationSuccessCard
                        } else {
                            invitationFormCard
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Provision Supervisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(viewModel.invitationSuccess ? "Close" : "Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invitation Failed", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred while provisioning supervisor credentials.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Form Card

    private var invitationFormCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .foregroundColor(AppTheme.emerald)
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Delegate Field Supervisor")
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("Provision operational staff for this estate with a temporary password.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            VStack(spacing: 14) {
                // Full Legal Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Legal Name")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("e.g. Kasun Jayawardena", text: $viewModel.fullName)
                            .autocapitalization(.words)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }

                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("Supervisor Email Address")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("e.g. kasun@nuwaraeliya.estate.lk", text: $viewModel.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }

                // Temporary Password
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Initial Temporary Password")
                            .font(.appCaption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button {
                            viewModel.regeneratePassword()
                            HapticFeedback.selection()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10))
                                Text("Generate")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.emerald)
                        }
                    }

                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("Temporary password", text: $viewModel.temporaryPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)

                    Text("The supervisor must rotate this password upon their first sign-in.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                }

                // Mobile Phone
                VStack(alignment: .leading, spacing: 6) {
                    Text("Field Radio / Contact Phone (Optional)")
                        .font(.appCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)

                        TextField("e.g. +94 77 987 6543", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding(14)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }

            Button {
                Task {
                    await viewModel.inviteSupervisor()
                }
            } label: {
                HStack {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(viewModel.isSubmitting ? "Provisioning..." : "Send Staff Credentials")
                        .font(.appHeadline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isFormValid ? AppTheme.emerald : AppTheme.emerald.opacity(0.4))
                .cornerRadius(12)
            }
            .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
            .accessibilityLabel("Send Staff Credentials")
        }
        .padding(18)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    // MARK: - Success Card

    private var invitationSuccessCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.emerald.opacity(0.14))
                    .frame(width: 60, height: 60)

                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(AppTheme.emerald)
            }

            VStack(spacing: 6) {
                Text("Supervisor Account Created")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Share these temporary credentials with the supervisor. They will be prompted to rotate the password immediately.")
                    .font(.appSubheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                credentialSummaryRow(label: "Full Name", value: viewModel.fullName)
                credentialSummaryRow(label: "Login Email", value: viewModel.email)
                credentialSummaryRow(label: "Temporary Password", value: viewModel.temporaryPassword)
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )

            Button {
                let shareText = """
                TeaYield AI Supervisor Credentials
                Name: \(viewModel.fullName)
                Email: \(viewModel.email)
                Temporary Password: \(viewModel.temporaryPassword)
                Note: Rotate credentials on first mobile sign-in.
                """
                UIPasteboard.general.string = shareText
                hasCopiedCredentials = true
                HapticFeedback.success()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: hasCopiedCredentials ? "checkmark" : "doc.on.doc.fill")
                    Text(hasCopiedCredentials ? "Credentials Copied to Clipboard" : "Copy Credentials")
                }
                .font(.appHeadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(hasCopiedCredentials ? AppTheme.navyDark : AppTheme.emerald)
                .cornerRadius(12)
            }

            Button {
                viewModel.resetForm()
                hasCopiedCredentials = false
            } label: {
                Text("Provision Another Supervisor")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }

    private func credentialSummaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.appCaption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}


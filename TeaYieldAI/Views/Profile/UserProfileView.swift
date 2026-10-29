import SwiftUI
import PhotosUI

/// Dedicated full-screen enterprise user profile view displaying officer credentials,
/// agronomic telemetry metrics, plantation sector assignment, hardware security tiers, and session controls.
@MainActor
struct UserProfileView: View {

    @StateObject private var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    init(
        authService: AuthServiceProtocol,
        apiService: APIServiceProtocol? = nil,
        harvestRepository: HarvestRepositoryProtocol? = nil,
        fieldRepository: FieldRepositoryProtocol? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: UserProfileViewModel(
                authService: authService,
                apiService: apiService,
                harvestRepository: harvestRepository,
                fieldRepository: fieldRepository
            )
        )
    }

    init(viewModel: UserProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        heroProfileCard
                        operationalTelemetryGrid
                        plantationAffiliationSection
                        deviceSecuritySection
                        AppearanceSettingsSectionView()
                        accountActionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.refreshProfileFromCloud()
                }
            }
            .navigationTitle("Officer Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Dismiss profile screen")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshProfileFromCloud()
                        }
                    } label: {
                        if viewModel.isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.emerald))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.emerald)
                        }
                    }
                    .accessibilityLabel("Refresh profile from cloud API")
                }
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $viewModel.showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    viewModel.logout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your authenticated session will end and return to the enterprise login screen. Local offline records remain preserved in Core Data.")
            }
            .alert("Profile Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred while communicating with the cloud backend.")
            }
            .applyAppTheme()
        }
    }

    // MARK: - Hero Profile Header

    private var heroProfileCard: some View {
        let currentProfileImage = viewModel.profileImage
        let currentInitials = viewModel.avatarInitials
        let hasCustomPhoto = currentProfileImage != nil

        return VStack(spacing: 14) {
            // Interactive Avatar with Camera Upload Badge
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let image = currentProfileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.emerald, lineWidth: 2.5)
                            )
                            .shadow(color: AppTheme.emerald.opacity(0.25), radius: 6, y: 2)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.emerald.opacity(0.18), AppTheme.emeraldLight.opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.emerald.opacity(0.35), lineWidth: 2)
                            )

                        Text(currentInitials)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.emerald)
                            .frame(width: 88, height: 88)
                    }

                    // Camera Edit Badge Icon
                    ZStack {
                        Circle()
                            .fill(AppTheme.emerald)
                            .frame(width: 28, height: 28)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color(uiColor: .secondarySystemGroupedBackground), lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile photo. Tap to choose from photo library.")
            .padding(.top, 4)
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.saveProfileImage(image)
                    }
                }
            }

            // Quick Photo Management Actions
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 5) {
                        Image(systemName: "photo.badge.plus")
                        Text(hasCustomPhoto ? "Change Photo" : "Upload Photo")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.emerald.opacity(0.10))
                    .cornerRadius(8)
                }

                if hasCustomPhoto {
                    Button {
                        viewModel.removeProfileImage()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Remove")
                        }
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.crimson)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.crimson.opacity(0.10))
                        .cornerRadius(8)
                    }
                }
            }

            // Officer Name & Role
            VStack(spacing: 6) {
                Text(viewModel.fullName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text(viewModel.roleTitle.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(viewModel.isManager ? Color.blue.opacity(0.14) : AppTheme.emerald.opacity(0.14))
                        .foregroundColor(viewModel.isManager ? Color.blue : AppTheme.emerald)
                        .cornerRadius(AppTheme.radiusSmall)

                    Text("ID: \(viewModel.employeeId)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.10))
                        .foregroundColor(.secondary)
                        .cornerRadius(AppTheme.radiusSmall)
                }

                HStack(spacing: 6) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(viewModel.email)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }

            if let success = viewModel.refreshSuccessMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.emerald)
                    Text(success)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.emerald.opacity(0.10))
                .cornerRadius(AppTheme.radiusSmall)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.fullName), \(viewModel.roleTitle), Employee ID \(viewModel.employeeId), Email \(viewModel.email)")
    }

    // MARK: - Agronomic Telemetry Grid

    private var operationalTelemetryGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OPERATIONAL FIELD IMPACT")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            HStack(spacing: 10) {
                metricCard(
                    title: "Total Weighed",
                    value: String(format: "%.1f kg", viewModel.totalHarvestedWeightKg),
                    icon: "scalemass.fill",
                    tint: AppTheme.emerald
                )

                metricCard(
                    title: "Weighing Logs",
                    value: "\(viewModel.cachedRecordsCount)",
                    icon: "tray.full.fill",
                    tint: .blue
                )
            }

            HStack(spacing: 10) {
                metricCard(
                    title: "Export Quality",
                    value: String(format: "%.1f%%", viewModel.averageFineLeafPercentage),
                    icon: "rosette",
                    tint: AppTheme.emerald
                )

                metricCard(
                    title: "Active Blocks",
                    value: "\(viewModel.cachedFieldsCount) Plots",
                    icon: "map.fill",
                    tint: AppTheme.amber
                )
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(tint)
                Spacer()
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .teaYieldCard(cornerRadius: AppTheme.radiusMedium)
    }

    // MARK: - Plantation Affiliation Section

    private var plantationAffiliationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ENTERPRISE PLANTATION ASSIGNMENT")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                infoRow(
                    icon: "building.2.fill",
                    tint: AppTheme.emerald,
                    label: "Primary Estate",
                    value: viewModel.estateDisplayName
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "square.split.2x2.fill",
                    tint: .blue,
                    label: "Division Sector",
                    value: viewModel.divisionName
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "mountain.2.fill",
                    tint: AppTheme.amber,
                    label: "Agro-Climatic Zone",
                    value: "Nuwara Eliya High-Grown (1,890m MSL)"
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "checkmark.seal.fill",
                    tint: AppTheme.emerald,
                    label: "Tea Board License",
                    value: "SLTB Lion Logo Certified (CE-TRI-2026)"
                )
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    // MARK: - Device Security Tier Section

    private var deviceSecuritySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEVICE HARDWARE & CRYPTOGRAPHY")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)

            VStack(spacing: 0) {
                infoRow(
                    icon: "faceid",
                    tint: AppTheme.emerald,
                    label: "Biometric Policy",
                    value: viewModel.biometryDescription
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "lock.shield.fill",
                    tint: .purple,
                    label: "Key Store",
                    value: "Apple Secure Enclave (AES-256)"
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "key.fill",
                    tint: .blue,
                    label: "Authorization",
                    value: "JWT 24-Hour Rolling Bearer"
                )

                Divider().padding(.leading, 46)

                infoRow(
                    icon: "cylinder.split.1x2.fill",
                    tint: AppTheme.emerald,
                    label: "Local Storage",
                    value: "Encrypted Core Data SQLite"
                )
            }
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    private func infoRow(icon: String, tint: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(tint)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Account Actions Section

    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.refreshProfileFromCloud()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.emerald))
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text("Sync Profile with Cloud API")
                        .fontWeight(.semibold)
                }
                .font(.appHeadline)
                .foregroundColor(AppTheme.emerald)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppTheme.emerald.opacity(0.10))
                .cornerRadius(AppTheme.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                        .stroke(AppTheme.emerald.opacity(0.25), lineWidth: 1)
                )
            }
            .disabled(viewModel.isRefreshing)
            .accessibilityLabel("Sync profile with cloud API")

            Button {
                viewModel.showingLogoutConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out of Enterprise Account")
                        .fontWeight(.bold)
                }
                .font(.appHeadline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.08))
                .cornerRadius(AppTheme.radiusMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
            }
            .accessibilityLabel("Log Out of Enterprise Account")
            .accessibilityHint("Prompts confirmation to sign out of the account")
        }
        .padding(.top, 4)
        .padding(.bottom, 24)
    }
}


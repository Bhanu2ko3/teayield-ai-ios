import SwiftUI

/// Header card displaying the authenticated field supervisor profile and division assignment.
struct OfficerProfileCardView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel
    var onViewFullProfileTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.emerald, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(AppTheme.emerald.opacity(0.12))
                            .frame(width: 58, height: 58)

                        Text(viewModel.avatarInitials)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.emerald)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.officerName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text(viewModel.officerRole)
                        .font(.appCaption)
                        .foregroundColor(.secondary)

                    if !viewModel.officerEmail.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)

                            Text(viewModel.officerEmail)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }

            Divider()
                .padding(.vertical, 2)

            VStack(spacing: 8) {
                HStack {
                    Text("Assigned Estate")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.estateName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }

                Divider()

                HStack {
                    Text("Division Access")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.divisionAssignment)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.emerald)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(10)
            .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.6))
            .cornerRadius(AppTheme.radiusMedium)

            if let onViewFullProfileTap = onViewFullProfileTap {
                Button(action: onViewFullProfileTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 13))
                        Text("View Full Profile")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(AppTheme.emerald.opacity(0.08))
                    .cornerRadius(AppTheme.radiusSmall)
                }
                .accessibilityLabel("View full profile")
            }
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

// MARK: - Previews

struct OfficerProfileCardView_Previews: PreviewProvider {
    static var previews: some View {
        OfficerProfileCardView(
            viewModel: SupervisorSettingsViewModel(
                authService: AppContainer.shared.authService,
                syncManager: AppContainer.shared.syncManager,
                fieldRepository: AppContainer.shared.fieldRepository,
                harvestRepository: AppContainer.shared.harvestRepository,
                apiService: AppContainer.shared.apiService
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


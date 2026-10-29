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

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.officerName)
                        .font(.appHeadline)
                        .foregroundColor(.primary)

                    Text("\(viewModel.officerRole) • ID: \(viewModel.officerEmployeeId)")
                        .font(.appCaption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Text(viewModel.officerEmail)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)

                        if viewModel.isAccountVerified {
                            Text("VERIFIED")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(AppTheme.emerald.opacity(0.15))
                                .foregroundColor(AppTheme.emerald)
                                .cornerRadius(AppTheme.radiusSmall)
                        }
                    }
                }

                Spacer()
            }

            Divider()
                .padding(.vertical, 2)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Assigned Estate")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(viewModel.estateName)
                        .font(.appCallout)
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Division Access")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(viewModel.divisionAssignment)
                        .font(.appCallout)
                        .foregroundColor(AppTheme.emerald)
                }
            }

            if let onViewFullProfileTap = onViewFullProfileTap {
                Button(action: onViewFullProfileTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 13))
                        Text("View Complete Enterprise Profile")
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
                .accessibilityLabel("View complete enterprise profile")
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


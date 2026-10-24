import SwiftUI

/// Header card displaying the authenticated field supervisor profile and division assignment.
struct OfficerProfileCardView: View {

    @ObservedObject var viewModel: SupervisorSettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.emerald.opacity(0.12))
                        .frame(width: 58, height: 58)

                    Text(viewModel.avatarInitials)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.emerald)
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
                                .cornerRadius(4)
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
        }
        .padding(16)
        .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
    }
}

import SwiftUI

/// Settings section providing user-controlled appearance switching between System Default, Light Mode, and Dark Mode.
struct AppearanceSettingsSectionView: View {

    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue
    var viewModel: SupervisorSettingsViewModel? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("APPEARANCE & THEME")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)

                Spacer()

                Text(currentMode.title.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.emerald.opacity(0.15))
                    .foregroundColor(AppTheme.emerald)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ForEach(AppThemeMode.allCases) { mode in
                        themeOptionButton(for: mode)
                    }
                }
            }
            .padding(14)
            .teaYieldCard(cornerRadius: AppTheme.radiusLarge)
        }
    }

    private var currentMode: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }

    private func themeOptionButton(for mode: AppThemeMode) -> some View {
        let isSelected = currentMode == mode

        return Button {
            HapticFeedback.selection()
            withAnimation(.easeInOut(duration: 0.2)) {
                appThemeMode = mode.rawValue
                viewModel?.setThemeMode(mode)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.emerald.opacity(0.18) : Color.secondary.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: mode.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? AppTheme.emerald : .secondary)
                }

                Text(mode.shortTitle)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? .primary : .secondary)

                if isSelected {
                    Circle()
                        .fill(AppTheme.emerald)
                        .frame(width: 5, height: 5)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                    .fill(isSelected ? AppTheme.emerald.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                    .stroke(isSelected ? AppTheme.emerald.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mode.title) Theme")
        .accessibilityHint(isSelected ? "Currently selected appearance" : "Double tap to switch application theme to \(mode.title)")
    }
}

// MARK: - Previews

struct AppearanceSettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsSectionView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}


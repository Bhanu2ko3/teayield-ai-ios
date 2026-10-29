import SwiftUI

/// Standardized appearance theme toggle component strictly conforming to Section 5 design guidelines.
/// Provides a crisp circular icon button with system/light/dark menu selection and haptic feedback.
struct ThemeToggleView: View {

    enum Style {
        case circle
        case iconOnly
        case pill
    }

    var style: Style = .circle
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue

    private var currentMode: AppThemeMode {
        AppThemeMode(rawValue: appThemeMode) ?? .system
    }

    var body: some View {
        Menu {
            ForEach(AppThemeMode.allCases) { mode in
                Button {
                    HapticFeedback.selection()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        appThemeMode = mode.rawValue
                    }
                } label: {
                    Label(mode.title, systemImage: mode.iconName)
                }
            }
        } label: {
            switch style {
            case .circle, .iconOnly:
                circleLabel
            case .pill:
                pillLabel
            }
        }
        .accessibilityLabel("Appearance Theme: currently \(currentMode.title)")
        .accessibilityHint("Double tap to switch between System Default, Light, and Dark modes")
    }

    // MARK: - Subviews

    private var circleLabel: some View {
        Image(systemName: currentMode.iconName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(AppTheme.emerald)
            .frame(width: 36, height: 36)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }

    private var pillLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: currentMode.iconName)
                .font(.system(size: 12, weight: .semibold))

            Text(currentMode.shortTitle)
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
}

// MARK: - Previews

struct ThemeToggleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ThemeToggleView(style: .circle)
            ThemeToggleView(style: .pill)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


import SwiftUI

/// User selectable application appearance theme mode.
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }

    var shortTitle: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Central design system tokens and typography for TeaYield AI.
/// Strictly conforms to Apple HIG and modern agritech emerald styling.
enum AppTheme {

    // MARK: - Semantic Color Palette

    /// Primary brand emerald representing peak harvest readiness and healthy vegetative chlorophyll (NDVI 0.75 - 0.85).
    static let emerald = Color(red: 0.02, green: 0.59, blue: 0.41) // #059669
    static let emeraldLight = Color(red: 0.06, green: 0.73, blue: 0.51) // #10B981
    static let emeraldDark = Color(red: 0.02, green: 0.47, blue: 0.34) // #047857

    /// Secondary amber gold representing mid-growth fields approaching harvest window in 3-5 days.
    static let amber = Color(red: 0.85, green: 0.47, blue: 0.02) // #D97706
    static let amberLight = Color(red: 0.96, green: 0.62, blue: 0.07) // #F59E0B

    /// Rest period crimson red representing recently plucked fields and rainfall hazard warnings.
    static let crimson = Color(red: 0.86, green: 0.15, blue: 0.15) // #DC2626
    static let crimsonLight = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444

    /// Neutral background and surface colors
    static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)
    static let surfaceCard = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceGlass = Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85)
    static let borderSubtle = Color.primary.opacity(0.08)

    // MARK: - Radius Tokens

    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusPill: CGFloat = 24
}

// MARK: - Color Extension Helpers

extension Color {
    static let emerald = AppTheme.emerald
    static let emeraldLight = AppTheme.emeraldLight
    static let amberGold = AppTheme.amber
    static let crimsonRest = AppTheme.crimson
}

// MARK: - Typography & Font Helpers (Native Dynamic Type Scaling)

extension Font {
    /// Modern rounded typography scale linked to Apple Dynamic Type text styles.
    static var appLargeTitle: Font {
        .system(.largeTitle, design: .rounded).weight(.bold)
    }

    static var appTitle: Font {
        .system(.title2, design: .rounded).weight(.bold)
    }

    static var appHeadline: Font {
        .system(.headline, design: .rounded).weight(.semibold)
    }

    static var appSubheadline: Font {
        .system(.subheadline, design: .rounded).weight(.medium)
    }

    static var appBody: Font {
        .system(.body, design: .default)
    }

    static var appCallout: Font {
        .system(.callout, design: .rounded).weight(.medium)
    }

    static var appFootnote: Font {
        .system(.footnote, design: .rounded)
    }

    static var appCaption: Font {
        .system(.caption, design: .rounded)
    }

    static var appBadge: Font {
        .system(.caption2, design: .rounded).weight(.bold)
    }
}

// MARK: - Reusable View Modifiers

struct TeaYieldCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.radiusLarge
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(cornerRadius)
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.04),
                radius: colorScheme == .dark ? 6 : 8,
                x: 0,
                y: colorScheme == .dark ? 2 : 3
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
    }
}

/// Applies user-selected or system appearance scheme across view hierarchies.
struct AppThemeModifier: ViewModifier {
    @AppStorage("appThemeMode") private var appThemeMode: String = AppThemeMode.system.rawValue

    var selectedScheme: ColorScheme? {
        AppThemeMode(rawValue: appThemeMode)?.colorScheme
    }

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(selectedScheme)
    }
}

extension View {
    func teaYieldCard(cornerRadius: CGFloat = AppTheme.radiusLarge) -> some View {
        modifier(TeaYieldCardModifier(cornerRadius: cornerRadius))
    }

    func applyAppTheme() -> some View {
        modifier(AppThemeModifier())
    }
}

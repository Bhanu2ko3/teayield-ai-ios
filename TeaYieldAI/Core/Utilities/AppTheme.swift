import SwiftUI

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
    static let borderSubtle = Color.black.opacity(0.06)

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

// MARK: - Typography & Font Helpers (Modern Rounded Aesthetic)

extension Font {
    /// Modern rounded typography scale providing clean, legible agritech dashboard font styling.
    static var appLargeTitle: Font {
        .system(size: 30, weight: .bold, design: .rounded)
    }

    static var appTitle: Font {
        .system(size: 22, weight: .bold, design: .rounded)
    }

    static var appHeadline: Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }

    static var appSubheadline: Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }

    static var appBody: Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    static var appCallout: Font {
        .system(size: 13, weight: .medium, design: .rounded)
    }

    static var appCaption: Font {
        .system(size: 12, weight: .regular, design: .rounded)
    }

    static var appBadge: Font {
        .system(size: 11, weight: .bold, design: .rounded)
    }
}

// MARK: - Reusable View Modifiers

struct TeaYieldCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.radiusLarge

    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
            )
    }
}

extension View {
    func teaYieldCard(cornerRadius: CGFloat = AppTheme.radiusLarge) -> some View {
        modifier(TeaYieldCardModifier(cornerRadius: cornerRadius))
    }
}

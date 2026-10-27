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

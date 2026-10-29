import SwiftUI

/// Standardized enterprise action button strictly conforming to Section 5.1 design system guidelines.
/// Provides consistent touch heights (50pt), loading indicator without layout shifts, and semantic styles.
struct TeaYieldButton: View {

    enum Style {
        case primary
        case secondary
        case destructive
        case tonal
    }

    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isLoading && !isDisabled else { return }
            HapticFeedback.lightImpact()
            action()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.9)
                }

                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }

                    Text(title)
                        .font(.appHeadline)
                        .fontWeight(.semibold)
                }
                .opacity(isLoading ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppTheme.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1.5 : 1)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled && !isLoading) ? 0.5 : 1.0)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Operation in progress" : "Double tap to activate")
    }

    // MARK: - Style Computations

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppTheme.emerald
        case .secondary:
            return Color.clear
        case .destructive:
            return AppTheme.crimson
        case .tonal:
            return AppTheme.emerald.opacity(0.12)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .tonal:
            return AppTheme.emerald
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return Color.clear
        case .secondary:
            return AppTheme.emerald.opacity(0.8)
        case .tonal:
            return AppTheme.emerald.opacity(0.2)
        }
    }
}

// MARK: - Previews

struct TeaYieldButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 14) {
            TeaYieldButton(title: "Confirm Green Leaf Weighing", icon: "scalemass.fill", style: .primary, action: {})
            TeaYieldButton(title: "Provision Subordinate Supervisor", icon: "person.badge.plus", style: .secondary, action: {})
            TeaYieldButton(title: "Sync Offline Records (3 Pending)", icon: "arrow.triangle.2.circlepath", style: .tonal, action: {})
            TeaYieldButton(title: "Discard Draft Log", icon: "trash.fill", style: .destructive, action: {})
            TeaYieldButton(title: "Optimizing Schedule...", style: .primary, isLoading: true, action: {})
            TeaYieldButton(title: "Disabled Action", style: .primary, isDisabled: true, action: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


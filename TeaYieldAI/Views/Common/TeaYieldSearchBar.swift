import SwiftUI

/// Reusable Apple Human Interface Guidelines-compliant search bar component.
/// Provides a modern, crisp industrial input with clear button, subtle border, and fluid focus feedback.
struct TeaYieldSearchBar: View {

    @Binding var text: String
    var placeholder: String = "Search..."
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isFocused ? AppTheme.emerald : .secondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .focused($isFocused)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                    HapticFeedback.selection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                .stroke(
                    isFocused ? AppTheme.emerald.opacity(0.5) : Color.primary.opacity(0.06),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(
            color: isFocused ? AppTheme.emerald.opacity(0.08) : Color.black.opacity(0.02),
            radius: 6,
            x: 0,
            y: 2
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
    }
}


import SwiftUI

struct ActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.buttonLabel)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(borderColor, lineWidth: style == .secondary ? 1 : 0)
                )
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: .accentPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: .accentPrimary
        case .secondary: .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: .clear
        case .secondary: .accentPrimary
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        ActionButton(title: "Primary Action", style: .primary) {}
        ActionButton(title: "Secondary Action", style: .secondary) {}
    }
    .padding()
    .background(Color.surface0)
}

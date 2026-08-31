import SwiftUI

/// Full-width accent button for the one primary action on a screen
/// (empty-state "Add your first fragrance", sheet "Save", etc.).
struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            if isLoading {
                ProgressView().tint(.white)
            }
            configuration.label
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .foregroundStyle(.white)
        .background(Theme.Palette.accent, in: RoundedRectangle(cornerRadius: Theme.Radius.md))
        .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
        .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(isLoading: Bool) -> PrimaryButtonStyle {
        PrimaryButtonStyle(isLoading: isLoading)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.lg) {
        Button("Add your first fragrance") {}
            .buttonStyle(.primary)
        Button("Saving…") {}
            .buttonStyle(.primary(isLoading: true))
        Button("Disabled") {}
            .buttonStyle(.primary)
            .disabled(true)
    }
    .padding()
}

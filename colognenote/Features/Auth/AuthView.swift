import SwiftUI

/// Placeholder for the sign-in / sign-up flow. Built out in Milestone 1.
struct AuthView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "drop.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Palette.accent)
            Text("Cologne")
                .font(Theme.Typography.display(34))
            Text("Sign in — coming in Milestone 1")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .padding()
    }
}

#Preview {
    AuthView()
}

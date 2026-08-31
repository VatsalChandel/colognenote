import SwiftUI

/// Centered spinner with an optional label. Use while a screen's first load is in flight.
struct LoadingView: View {
    var label: String?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ProgressView()
            if let label {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Friendly empty state: icon, title, message, and an optional call to action.
struct EmptyStateView: View {
    var systemImage: String = "sparkles"
    var title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(Theme.Palette.tertiaryText)
            Text(title)
                .font(Theme.Typography.display(22))
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.secondaryText)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.primary)
                    .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Error state with a retry affordance.
struct ErrorView: View {
    var message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Palette.destructive)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.secondaryText)
                .multilineTextAlignment(.center)
            if let retry {
                Button("Try again", action: retry)
                    .buttonStyle(.bordered)
                    .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Loading") { LoadingView(label: "Loading your shelf…") }

#Preview("Empty") {
    EmptyStateView(
        systemImage: "drop.halffull",
        title: "Your shelf is empty",
        message: "Add your first fragrance to start tracking wears and compliments.",
        actionTitle: "Add your first fragrance",
        action: {}
    )
}

#Preview("Error") {
    ErrorView(message: "We couldn't reach the server. Check your connection.", retry: {})
}

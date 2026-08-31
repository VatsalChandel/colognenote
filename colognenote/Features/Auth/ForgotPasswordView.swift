import SwiftUI

/// Sends a Supabase password-reset email. The link opens Supabase's hosted reset
/// page for now; an in-app deep-link reset screen can come later.
struct ForgotPasswordView: View {
    var initialEmail: String = ""

    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isSubmitting = false
    @State private var sent = false
    @State private var errorMessage: String?

    private let auth = AuthService()

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.lg) {
                if sent {
                    EmptyStateView(
                        systemImage: "envelope.badge",
                        title: "Check your email",
                        message: "If an account exists for \(email), a reset link is on its way."
                    )
                } else {
                    Text("Enter your email and we'll send a reset link.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(Theme.Spacing.md)
                        .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(Theme.Palette.destructive)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("Send reset link") { Task { await send() } }
                        .buttonStyle(.primary(isLoading: isSubmitting))
                        .disabled(!email.isValidEmail || isSubmitting)

                    Spacer()
                }
            }
            .padding(Theme.Spacing.xl)
            .navigationTitle("Reset password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { if email.isEmpty { email = initialEmail } }
        }
    }

    private func send() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await auth.sendPasswordReset(email: email.trimmed)
            sent = true
        } catch {
            errorMessage = AuthViewModel.friendlyMessage(for: error)
        }
    }
}

#Preview {
    ForgotPasswordView(initialEmail: "you@example.com")
}

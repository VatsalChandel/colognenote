import Foundation
import Observation
import Supabase

/// Backs ``AuthView`` — one form that toggles between sign in and sign up.
/// On success, `SessionStore` picks up the auth-state change and routes onward.
@Observable
@MainActor
final class AuthViewModel {

    enum Mode: Equatable { case signIn, signUp }

    var mode: Mode = .signIn
    var email = ""
    var password = ""
    var displayName = ""
    var isSubmitting = false
    var errorMessage: String?

    private let auth = AuthService()

    var title: String { mode == .signIn ? "Welcome back" : "Create your account" }
    var submitLabel: String { mode == .signIn ? "Sign in" : "Sign up" }
    var switchPrompt: String {
        mode == .signIn ? "New here? Create an account" : "Already have an account? Sign in"
    }

    var canSubmit: Bool {
        guard !isSubmitting, email.isValidEmail, password.count >= 6 else { return false }
        return mode == .signIn || !displayName.trimmed.isEmpty
    }

    func toggleMode() {
        mode = mode == .signIn ? .signUp : .signIn
        errorMessage = nil
    }

    func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            switch mode {
            case .signIn:
                try await auth.signIn(email: email.trimmed, password: password)
            case .signUp:
                try await auth.signUp(
                    email: email.trimmed,
                    password: password,
                    displayName: displayName.trimmed
                )
            }
        } catch {
            errorMessage = Self.friendlyMessage(for: error)
        }
    }

    static func friendlyMessage(for error: Error) -> String {
        if let authError = error as? AuthError {
            let code = authError.errorCode
            if code == .invalidCredentials {
                return "That email and password don't match an account."
            } else if code == .weakPassword {
                return "That password is too weak — use at least 6 characters."
            } else if code == .userAlreadyExists || code == .emailExists {
                return "An account with that email already exists. Try signing in instead."
            } else if code == .validationFailed {
                return "That doesn't look like a valid email address."
            }
            return authError.message
        }
        return error.localizedDescription
    }
}

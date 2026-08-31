import Foundation
import Supabase

/// Thin wrapper over `supabase.auth` for the sign-in / sign-up / reset flows.
/// Session persistence, auto-login and token refresh are handled by the SDK and
/// observed in ``SessionStore``.
struct AuthService {

    /// Create an account. With "Confirm email" off in Supabase, this returns an
    /// active session immediately and `authStateChanges` fires `.signedIn`.
    /// `displayName` is stashed in user metadata; the DB trigger seeds a
    /// placeholder `profiles.username` that the user replaces in profile setup.
    func signUp(email: String, password: String, displayName: String?) async throws {
        var data: [String: AnyJSON] = [:]
        if let displayName, !displayName.isEmpty {
            data["display_name"] = .string(displayName)
        }
        _ = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: data.isEmpty ? nil : data
        )
    }

    func signIn(email: String, password: String) async throws {
        _ = try await supabase.auth.signIn(email: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}

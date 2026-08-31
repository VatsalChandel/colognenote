import Foundation
import Observation
import Supabase

/// Single source of truth for auth state. Drives root routing (see task 1.6).
/// Phase 1 routing is coarse — signed in or not; profile-completeness and the
/// zero-bottles empty state are layered on in Milestone 1.
@Observable
@MainActor
final class SessionStore {

    enum State: Equatable {
        case loading
        case signedOut
        case signedIn
    }

    private(set) var state: State = .loading
    private(set) var userID: UUID?

    /// Start listening. Call once, from the app entry point's `.task`.
    func start() async {
        apply(session: supabase.auth.currentSession)

        for await change in supabase.auth.authStateChanges {
            switch change.event {
            case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                apply(session: change.session)
            case .signedOut:
                state = .signedOut
                userID = nil
            case .passwordRecovery, .mfaChallengeVerified:
                break
            @unknown default:
                break
            }
        }
    }

    func signOut() async {
        try? await supabase.auth.signOut()
        state = .signedOut
        userID = nil
    }

    private func apply(session: Session?) {
        if let session {
            userID = session.user.id
            state = .signedIn
        } else {
            state = .signedOut
        }
    }
}

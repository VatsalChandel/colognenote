import Foundation
import Observation
import Supabase

/// Single source of truth for auth + onboarding state. Drives root routing (task 1.6):
///
///   .loading           → splash
///   .signedOut         → AuthView
///   .needsProfileSetup → ProfileSetupView   (username still the DB placeholder)
///   .ready(profile)    → MainTabView
///
/// The zero-bottles empty state is handled inside the Collection screen, not here.
@Observable
@MainActor
final class SessionStore {

    enum Phase: Equatable {
        case loading
        case signedOut
        case needsProfileSetup
        case ready(Profile)
    }

    private(set) var phase: Phase = .loading
    private(set) var userID: UUID?

    private let profiles = ProfileRepository()

    /// Start listening. Call once, from the app entry point's `.task`.
    func start() async {
        await resolve(session: supabase.auth.currentSession)

        for await change in supabase.auth.authStateChanges {
            switch change.event {
            case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                await resolve(session: change.session)
            case .signedOut:
                phase = .signedOut
                userID = nil
            case .passwordRecovery, .mfaChallengeVerified:
                break
            @unknown default:
                break
            }
        }
    }

    /// Re-fetch the profile and recompute the phase — call after profile setup saves.
    func refreshProfile() async {
        await resolve(session: supabase.auth.currentSession)
    }

    func signOut() async {
        try? await supabase.auth.signOut()
        phase = .signedOut
        userID = nil
    }

    private func resolve(session: Session?) async {
        guard let session else {
            phase = .signedOut
            userID = nil
            return
        }
        userID = session.user.id
        do {
            let profile = try await profiles.currentProfile()
            phase = profile.needsSetup ? .needsProfileSetup : .ready(profile)
        } catch {
            // Trigger may not have committed the profile row yet on a brand-new
            // sign-up; treat as "needs setup" so the user lands somewhere sane.
            phase = .needsProfileSetup
        }
    }
}

import Foundation
import Supabase

struct ProfileRepository {

    /// The signed-in user's profile row (auto-created by a DB trigger at sign-up).
    func currentProfile() async throws -> Profile {
        let id = try currentUserID()
        return try await supabase
            .from(Table.profiles)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    /// Is this username free? Uses the `username_available` SECURITY DEFINER function
    /// (docs/1-auth-support.sql) because Phase 1 RLS hides other users' profile rows.
    func usernameAvailable(_ candidate: String) async throws -> Bool {
        try await supabase
            .rpc("username_available", params: ["candidate": candidate])
            .execute()
            .value
    }

    /// First-run setup and Settings → Edit profile.
    func update(
        username: String? = nil,
        displayName: String? = nil,
        bio: String? = nil,
        avatarUrl: String? = nil,
        showCollectionValue: Bool? = nil
    ) async throws -> Profile {
        let id = try currentUserID()
        let patch = ProfilePatch(
            username: username,
            displayName: displayName,
            bio: bio,
            avatarUrl: avatarUrl,
            showCollectionValue: showCollectionValue
        )
        return try await supabase
            .from(Table.profiles)
            .update(patch)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    private struct ProfilePatch: Encodable {
        let username: String?
        let displayName: String?
        let bio: String?
        let avatarUrl: String?
        let showCollectionValue: Bool?
    }
}

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

    func profileExists(username: String) async throws -> Bool {
        let count = try await supabase
            .from(Table.profiles)
            .select("id", head: true, count: .exact)
            .eq("username", value: username)
            .execute()
            .count
        return (count ?? 0) > 0
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

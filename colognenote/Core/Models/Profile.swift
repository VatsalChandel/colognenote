import Foundation

/// `profiles` — extends Supabase's `auth.users`. A row is auto-created by a DB trigger
/// on sign-up, then completed in the first-run profile setup.
struct Profile: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var username: String
    var displayName: String?
    var avatarUrl: String?
    var bio: String?
    /// The one opt-in flex. Default false; price itself is never exposed regardless.
    var showCollectionValue: Bool
    var createdAt: Date?

    /// The DB trigger seeds `username` as `user_<first 8 of the uuid>`. While it
    /// still matches that shape, the user hasn't been through profile setup.
    var needsSetup: Bool {
        username.wholeMatch(of: #/user_[0-9a-f]{8}/#) != nil
    }
}

extension Profile {
    /// Usernames the user can't pick — the reserved auto-generated prefix.
    static let reservedUsernamePrefix = "user_"
}

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
}

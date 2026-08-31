import Foundation

/// `follows` — the social graph. Modelled now so the schema mapping is complete;
/// **not used in Phase 1** (no follow/unfollow UI until the social layer).
struct Follow: Codable, Hashable, Sendable {
    let followerId: UUID
    let followeeId: UUID
    var createdAt: Date?
}

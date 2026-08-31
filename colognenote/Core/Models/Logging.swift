import Foundation

/// `wear_logs` — the core event. Fast to create (a sheet, never a form).
/// `season` is derived from `wornOn` at read time, not stored.
struct WearLog: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    let collectionItemId: UUID
    /// Postgres `date` — "yyyy-MM-dd". Defaults to today server-side.
    var wornOn: String
    var occasion: Occasion?
    /// Weather is captured once at log time and snapshotted here — never re-fetched.
    var weatherTemp: Double?
    var weatherCondition: String?
    /// An SOTD is just a wear posted publicly (Phase 2). Stored now, surfaced later.
    var isSotd: Bool
    var pairing: String?
    var createdAt: Date?
}

/// `compliments` — attached to a wear, or left loose (`wearLogId == nil`) to attach later.
struct Compliment: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    let collectionItemId: UUID
    var wearLogId: UUID?
    /// Postgres `date` — "yyyy-MM-dd".
    var complimentedOn: String
    var who: String?
    var comment: String?
    var createdAt: Date?
}

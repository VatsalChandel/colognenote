import Foundation

// Canonical layer — the shared vocabulary and fragrance records. World-readable for
// verified/canonical rows; users never author notes or accords directly.

/// `accord_families` — the fixed 16-family vocabulary analytics roll up to.
struct AccordFamily: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
}

/// `notes` — the growing pick-list. Each note maps to exactly one accord family.
struct Note: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let familyId: Int
}

/// `fragrances` — the canonical thing (future) social features count.
struct Fragrance: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var house: String?
    var concentration: Concentration?
    var yearReleased: Int?
    var imageUrl: String?
    var tier: FragranceTier
    var status: FragranceStatus
    var submittedBy: UUID?
    var createdAt: Date?
}

/// `fragrance_notes` — pyramid join (composite key, no surrogate id).
struct FragranceNote: Codable, Hashable, Sendable {
    let fragranceId: UUID
    let noteId: Int
    let position: PyramidPosition
}

/// `fragrance_accords` view — a fragrance's accords, derived from its notes' families.
struct FragranceAccord: Codable, Hashable, Sendable {
    let fragranceId: UUID
    let familyId: Int
    let familyName: String
}

import Foundation

// Controlled vocabularies. Raw values match the Postgres enum labels / CHECK values
// exactly (see docs/supabase-schema.sql). Key-casing conversion never touches values,
// so multi-word labels keep their snake_case / spaced form here.

/// `fragrances.tier` — canonical entries feed future community stats; personal ones don't.
enum FragranceTier: String, Codable, CaseIterable, Sendable {
    case canonical
    case personal
}

/// `fragrances.status` — the moderation gate for crowdsourced entries.
enum FragranceStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case verified
}

/// `collection_items.status` — items are normally retired, not deleted, so history survives.
enum ItemStatus: String, Codable, CaseIterable, Sendable {
    case active
    case finished
    case sold
}

/// `fragrance_notes.position` — where a note sits in the pyramid.
enum PyramidPosition: String, Codable, CaseIterable, Sendable {
    case top
    case middle
    case base
}

/// `wishlist_items.stage` — the sampling funnel.
enum WishlistStage: String, Codable, CaseIterable, Sendable {
    case sampled
    case considering
    case wantBottle = "want_bottle"
}

/// `fragrances.concentration` — text + CHECK in the schema (extensible), modelled as an enum.
enum Concentration: String, Codable, CaseIterable, Sendable {
    case edc = "EDC"
    case edt = "EDT"
    case edp = "EDP"
    case parfum = "Parfum"
    case extrait = "Extrait"
    case eauFraiche = "Eau Fraiche"
    case elixir = "Elixir"
}

/// `wear_logs.occasion` — text + CHECK in the schema (extensible), modelled as an enum.
enum Occasion: String, Codable, CaseIterable, Sendable {
    case office
    case date
    case gym
    case formal
    case casual
    case nightOut = "night_out"
}

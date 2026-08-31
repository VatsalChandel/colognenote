import Foundation

/// A collection row plus the per-item aggregates the grid sorts and filters on.
/// All computed on read (blueprint §4) — fine at Phase 1 collection sizes.
struct EnrichedItem: Identifiable, Hashable, Sendable {
    let row: CollectionItemRow
    let wearCount: Int
    /// **[PRIVATE]** — from `collection_item_costs`.
    let price: Decimal?
    /// Derived accord family names for this item's fragrance.
    let accordFamilies: [String]

    var id: UUID { row.id }
    var fragrance: Fragrance { row.fragrance }

    /// **[PRIVATE]** — `price / wears`, nil until there's a price and at least one wear.
    var costPerWear: Decimal? {
        guard let price, wearCount > 0 else { return nil }
        return price / Decimal(wearCount)
    }
}

enum CollectionSort: String, CaseIterable, Identifiable {
    case recent      = "Recently added"
    case rating      = "Rating"
    case mostWorn    = "Most worn"
    case house       = "House"
    case costPerWear = "Cost per wear"

    var id: String { rawValue }
}

struct CollectionFilter: Equatable {
    /// nil = show every status; defaults to active-only.
    var status: ItemStatus? = .active
    var house: String?
    var accord: String?

    var isNarrowed: Bool { status != .active || house != nil || accord != nil }
}

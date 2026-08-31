import Foundation

/// `collection_items` — one row per fragrance owned. Public-facing fields only.
/// Price is deliberately NOT here; it lives in ``CollectionItemCost``.
struct CollectionItem: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    var fragranceId: UUID
    var sizeMl: Int?
    /// Postgres `date` — "yyyy-MM-dd".
    var purchaseDate: String?
    var purchaseLocation: String?
    var batchCode: String?
    /// Rough %, 0–100, manual slider.
    var fillLevel: Int?
    /// 1–5.
    var personalRating: Int?
    var status: ItemStatus
    var photoUrl: String?
    var createdAt: Date?
}

/// `collection_item_costs` — price isolated in its own table so RLS keeps it owner-only
/// even after the rest of the shelf goes public in Phase 2. **[PRIVATE]**
struct CollectionItemCost: Codable, Identifiable, Hashable, Sendable {
    /// PK is the item id (one cost row per item).
    let collectionItemId: UUID
    let userId: UUID
    var price: Decimal
    var currency: String

    var id: UUID { collectionItemId }
}

/// `my_collection_value` view — the caller's own active-collection total. **[PRIVATE]**
struct CollectionValue: Codable, Hashable, Sendable {
    let userId: UUID
    let totalValue: Decimal
    let itemCount: Int
}

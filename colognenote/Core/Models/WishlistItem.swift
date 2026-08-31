import Foundation

/// `wishlist_items` — the sampling funnel. References a canonical fragrance OR free text
/// (the schema enforces at least one is present).
struct WishlistItem: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    var fragranceId: UUID?
    var fragranceFreetext: String?
    var stage: WishlistStage
    var targetPrice: Decimal?
    var notes: String?
    var createdAt: Date?
}

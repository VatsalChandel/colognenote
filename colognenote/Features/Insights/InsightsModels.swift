import Foundation

/// One owned bottle with the numbers Insights ranks on. Active items only.
struct InsightItem: Identifiable, Hashable, Sendable {
    let id: UUID            // collection item id — for tap-through
    let name: String
    let house: String?
    let imageURL: String?
    let wearCount: Int
    let complimentCount: Int
    /// **[PRIVATE]**
    let price: Decimal?
    /// "yyyy-MM-dd", or nil if never worn.
    let lastWorn: String?
    let accordFamilies: [String]

    /// **[PRIVATE]**
    var costPerWear: Decimal? {
        guard let price, wearCount > 0 else { return nil }
        return price / Decimal(wearCount)
    }
}

/// Item count for one accord family — feeds the breakdown chart.
struct AccordCount: Identifiable, Hashable, Sendable {
    let family: String
    let count: Int
    var id: String { family }
}

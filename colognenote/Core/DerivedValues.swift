import Foundation

/// Single source of truth for the values the app computes on read (task 6.4).
/// Collection value itself comes from the `my_collection_value` DB view.
enum DerivedValues {

    /// **[PRIVATE]** cost-per-wear = price ÷ wears. `nil` until there's a price
    /// and at least one wear.
    static func costPerWear(price: Decimal?, wears: Int) -> Decimal? {
        guard let price, wears > 0 else { return nil }
        return price / Decimal(wears)
    }

    enum Season: String, CaseIterable, Sendable {
        case spring, summer, autumn, winter

        var label: String { rawValue.capitalized }
    }

    /// Northern-hemisphere meteorological season for a date.
    static func season(from date: Date) -> Season {
        switch Calendar.current.component(.month, from: date) {
        case 3...5:  .spring
        case 6...8:  .summer
        case 9...11: .autumn
        default:     .winter
        }
    }

    /// Season from a Postgres `date` string ("yyyy-MM-dd").
    static func season(fromISODate iso: String) -> Season? {
        ISODate.date(from: iso).map(season(from:))
    }
}

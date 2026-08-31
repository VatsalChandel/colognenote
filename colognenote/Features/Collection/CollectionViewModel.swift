import Foundation
import Observation

@Observable
@MainActor
final class CollectionViewModel {

    enum State: Equatable {
        case loading
        case ready          // has at least one item (possibly filtered to zero)
        case empty          // owns nothing at all
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var allItems: [EnrichedItem] = []
    private(set) var value: CollectionValue?

    // Controls
    var searchText = ""
    var sort: CollectionSort = .recent
    var filter = CollectionFilter()

    private let collection = CollectionRepository()
    private let fragrances = FragranceRepository()

    // MARK: Derived

    var displayedItems: [EnrichedItem] {
        var items = allItems

        if let status = filter.status {
            items = items.filter { $0.row.status == status }
        }
        if let house = filter.house {
            items = items.filter { $0.fragrance.house == house }
        }
        if let accord = filter.accord {
            items = items.filter { $0.accordFamilies.contains(accord) }
        }
        let query = searchText.trimmed.lowercased()
        if !query.isEmpty {
            items = items.filter {
                $0.fragrance.name.lowercased().contains(query)
                || ($0.fragrance.house?.lowercased().contains(query) ?? false)
            }
        }
        return sorted(items)
    }

    var houseOptions: [String] {
        Set(allItems.compactMap { $0.fragrance.house }).sorted()
    }

    var accordOptions: [String] {
        Set(allItems.flatMap(\.accordFamilies)).sorted()
    }

    private func sorted(_ items: [EnrichedItem]) -> [EnrichedItem] {
        switch sort {
        case .recent:
            return items.sorted { ($0.row.createdAt ?? .distantPast) > ($1.row.createdAt ?? .distantPast) }
        case .rating:
            return items.sorted { ($0.row.personalRating ?? 0) > ($1.row.personalRating ?? 0) }
        case .mostWorn:
            return items.sorted { $0.wearCount > $1.wearCount }
        case .house:
            return items.sorted { ($0.fragrance.house ?? "").localizedCaseInsensitiveCompare($1.fragrance.house ?? "") == .orderedAscending }
        case .costPerWear:
            // Items with a CPW first (ascending — cheapest per wear on top), then the rest.
            return items.sorted { lhs, rhs in
                switch (lhs.costPerWear, rhs.costPerWear) {
                case let (l?, r?): return l < r
                case (.some, .none): return true
                case (.none, .some): return false
                case (.none, .none): return false
                }
            }
        }
    }

    // MARK: Load

    func load() async {
        do {
            async let rowsTask = collection.allItems()
            async let valueTask = collection.collectionValue()
            async let wearsTask = collection.wearCountsByItem()
            async let pricesTask = collection.pricesByItem()

            let rows = try await rowsTask
            let fragranceIDs = Array(Set(rows.map(\.fragranceId)))
            let accords = try await fragrances.accordFamiliesByFragrance(ids: fragranceIDs)
            let (value, wears, prices) = try await (valueTask, wearsTask, pricesTask)

            self.value = value
            self.allItems = rows.map { row in
                EnrichedItem(
                    row: row,
                    wearCount: wears[row.id] ?? 0,
                    price: prices[row.id],
                    accordFamilies: accords[row.fragranceId] ?? []
                )
            }
            state = allItems.isEmpty ? .empty : .ready
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Couldn't load your collection.")
        }
    }
}

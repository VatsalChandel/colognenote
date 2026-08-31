import Foundation
import Observation

@Observable
@MainActor
final class InsightsViewModel {

    enum State: Equatable {
        case loading
        case coldStart      // not enough data yet
        case ready
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var items: [InsightItem] = []
    private(set) var accordCounts: [AccordCount] = []
    private(set) var gapFamilies: [String] = []
    private(set) var value: CollectionValue?

    private let collection = CollectionRepository()
    private let fragrances = FragranceRepository()
    private let wears = WearLogRepository()
    private let compliments = ComplimentRepository()
    private let catalog = CatalogRepository()

    // MARK: Derived rankings

    var totalWears: Int { items.reduce(0) { $0 + $1.wearCount } }

    var mostWorn: [InsightItem] {
        items.filter { $0.wearCount > 0 }
            .sorted { $0.wearCount > $1.wearCount }
            .prefix(5).map { $0 }
    }

    /// Never-worn first, then longest since last worn.
    var mostNeglected: [InsightItem] {
        items.sorted { ($0.lastWorn ?? "") < ($1.lastWorn ?? "") }
            .prefix(5).map { $0 }
    }

    var bestPerformers: [InsightItem] {
        items.filter { $0.complimentCount > 0 }
            .sorted { $0.complimentCount > $1.complimentCount }
            .prefix(5).map { $0 }
    }

    /// Best value (lowest cost-per-wear) first. Only items with a price and a wear.
    var byCostPerWear: [InsightItem] {
        items.filter { $0.costPerWear != nil }
            .sorted { ($0.costPerWear ?? 0) < ($1.costPerWear ?? 0) }
    }

    // MARK: Load

    func load() async {
        do {
            async let rowsTask = collection.activeItems()
            async let wearStatsTask = wears.statsByItem()
            async let complimentCountsTask = compliments.complimentCountsByItem()
            async let pricesTask = collection.pricesByItem()
            async let valueTask = collection.collectionValue()
            async let familiesTask = catalog.accordFamilies()

            let rows = try await rowsTask
            let fragranceIDs = Array(Set(rows.map(\.fragranceId)))
            let accords = try await fragrances.accordFamiliesByFragrance(ids: fragranceIDs)
            let (wearStats, complimentCounts, prices, value, allFamilies) =
                try await (wearStatsTask, complimentCountsTask, pricesTask, valueTask, familiesTask)

            self.value = value
            self.items = rows.map { row in
                InsightItem(
                    id: row.id,
                    name: row.fragrance.name,
                    house: row.fragrance.house,
                    imageURL: row.photoUrl ?? row.fragrance.imageUrl,
                    wearCount: wearStats.counts[row.id] ?? 0,
                    complimentCount: complimentCounts[row.id] ?? 0,
                    price: prices[row.id],
                    lastWorn: wearStats.lastWorn[row.id],
                    accordFamilies: accords[row.fragranceId] ?? []
                )
            }

            // Accord breakdown + gaps, over the fixed 16-family vocabulary.
            var tally: [String: Int] = [:]
            for item in items {
                for family in item.accordFamilies { tally[family, default: 0] += 1 }
            }
            let familyNames = allFamilies.map(\.name)
            self.accordCounts = familyNames
                .map { AccordCount(family: $0, count: tally[$0] ?? 0) }
                .filter { $0.count > 0 }
                .sorted { $0.count > $1.count }
            self.gapFamilies = familyNames.filter { (tally[$0] ?? 0) == 0 }

            state = (items.isEmpty || totalWears == 0) ? .coldStart : .ready
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Couldn't load your insights.")
        }
    }
}

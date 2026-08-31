import Foundation
import Observation

@Observable
@MainActor
final class BottleDetailViewModel {

    enum State: Equatable {
        case loading
        case loaded
        case failed(String)
        case deleted        // item removed — the view pops
    }

    let itemID: UUID
    private(set) var state: State = .loading

    private(set) var item: CollectionItemRow?
    private(set) var cost: CollectionItemCost?
    private(set) var notesByPosition: [PyramidPosition: [String]] = [:]
    private(set) var accords: [String] = []
    private(set) var wears: [WearLog] = []
    private(set) var compliments: [Compliment] = []

    /// Local echo of the fill slider so dragging feels immediate.
    var fillLevel: Double = 0

    private let collection = CollectionRepository()
    private let fragrances = FragranceRepository()
    private let wearRepo = WearLogRepository()
    private let complimentRepo = ComplimentRepository()

    init(itemID: UUID) { self.itemID = itemID }

    // MARK: Derived

    var wearCount: Int { wears.count }
    var complimentCount: Int { compliments.count }

    /// **[PRIVATE]**
    var costPerWear: Decimal? { DerivedValues.costPerWear(price: cost?.price, wears: wearCount) }

    var hasPyramid: Bool { !notesByPosition.isEmpty }

    // MARK: Load

    func load() async {
        do {
            // Need the item first for its fragrance id, then fan out.
            async let itemTask = collection.item(id: itemID)
            async let costTask = collection.cost(itemID: itemID)
            async let wearsTask = wearRepo.wears(itemID: itemID)
            async let complimentsTask = complimentRepo.compliments(itemID: itemID)

            let item = try await itemTask
            self.item = item
            self.fillLevel = Double(item.fillLevel ?? 0)

            async let noteDetailTask = fragrances.notes(fragranceID: item.fragranceId)
            async let accordTask = fragrances.accords(fragranceID: item.fragranceId)

            let (cost, wears, compliments, noteDetails, accordRows) =
                try await (costTask, wearsTask, complimentsTask, noteDetailTask, accordTask)

            self.cost = cost
            self.wears = wears
            self.compliments = compliments
            self.notesByPosition = Dictionary(grouping: noteDetails, by: \.position)
                .mapValues { $0.map(\.note.name) }
            self.accords = accordRows.map(\.familyName).sorted()
            state = .loaded
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Couldn't load this bottle.")
        }
    }

    // MARK: Mutations

    func setStatus(_ status: ItemStatus) async {
        guard let item, item.status != status else { return }
        try? await collection.setStatus(id: itemID, status)
        await load()
    }

    func commitFillLevel() async {
        try? await collection.setFillLevel(id: itemID, Int(fillLevel.rounded()))
    }

    func deleteItem() async {
        do {
            try await collection.delete(id: itemID)
            state = .deleted
        } catch {
            state = .failed("Couldn't delete this bottle.")
        }
    }

    func deleteWear(_ id: UUID) async {
        try? await wearRepo.delete(id: id)
        await load()
    }

    func deleteCompliment(_ id: UUID) async {
        try? await complimentRepo.delete(id: id)
        await load()
    }

    func reload() async { await load() }
}

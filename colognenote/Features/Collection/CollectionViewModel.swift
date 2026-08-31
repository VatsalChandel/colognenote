import Foundation
import Observation

@Observable
@MainActor
final class CollectionViewModel {

    enum State: Equatable {
        case loading
        case empty
        case loaded([CollectionItemRow])
        case failed(String)
    }

    private(set) var state: State = .loading
    private let collection = CollectionRepository()

    func load() async {
        do {
            let items = try await collection.activeItems()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Couldn't load your collection.")
        }
    }
}

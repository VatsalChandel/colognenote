import Foundation
import Observation

@Observable
@MainActor
final class WishlistViewModel {

    enum State: Equatable {
        case loading
        case empty
        case ready
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var rows: [WishlistRow] = []

    private let repo = WishlistRepository()

    func rows(for stage: WishlistStage) -> [WishlistRow] {
        rows.filter { $0.stage == stage }
    }

    func load() async {
        do {
            let rows = try await repo.rows()
            self.rows = rows
            state = rows.isEmpty ? .empty : .ready
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Couldn't load your wishlist.")
        }
    }

    func setStage(_ row: WishlistRow, to stage: WishlistStage) async {
        try? await repo.setStage(id: row.id, stage)
        await load()
    }

    func delete(_ row: WishlistRow) async {
        try? await repo.delete(id: row.id)
        await load()
    }
}

extension WishlistStage {
    var label: String {
        switch self {
        case .sampled:     "Sampled"
        case .considering: "Considering"
        case .wantBottle:  "Want a bottle"
        }
    }

    /// The next step in the funnel, if any.
    var next: WishlistStage? {
        switch self {
        case .sampled:     .considering
        case .considering: .wantBottle
        case .wantBottle:  nil
        }
    }
}

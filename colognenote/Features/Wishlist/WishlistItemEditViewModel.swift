import Foundation
import Observation

/// Add or edit a wishlist item (task 5.2).
@Observable
@MainActor
final class WishlistItemEditViewModel {

    let editingID: UUID?

    // Fragrance identity — a canonical pick or free text.
    var query = ""
    private(set) var results: [Fragrance] = []
    private(set) var isSearching = false
    private(set) var chosenFragrance: Fragrance?
    var freeText = ""

    var stage: WishlistStage = .considering
    var targetPriceText = ""
    var notes = ""

    var isSaving = false
    var errorMessage: String?

    private let fragranceRepo = FragranceRepository()
    private let repo = WishlistRepository()
    private var searchTask: Task<Void, Never>?

    var isEditing: Bool { editingID != nil }
    var hasIdentity: Bool { chosenFragrance != nil || !freeText.trimmed.isEmpty }

    var canSave: Bool {
        guard !isSaving, hasIdentity else { return false }
        if !targetPriceText.isEmpty, Decimal(string: targetPriceText) == nil { return false }
        return true
    }

    init(editing row: WishlistRow? = nil) {
        if let row {
            editingID = row.id
            chosenFragrance = row.fragrance
            freeText = row.fragrance == nil ? (row.fragranceFreetext ?? "") : ""
            stage = row.stage
            targetPriceText = row.targetPrice.map { "\($0)" } ?? ""
            notes = row.notes ?? ""
        } else {
            editingID = nil
        }
    }

    func search() {
        searchTask?.cancel()
        let text = query.trimmed
        guard text.count >= 2 else { results = []; return }
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            results = (try? await fragranceRepo.searchCanonical(text)) ?? []
        }
    }

    func choose(_ fragrance: Fragrance) {
        chosenFragrance = fragrance
        freeText = ""
        results = []
        query = ""
    }

    func clearChoice() {
        chosenFragrance = nil
    }

    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        let price = targetPriceText.isEmpty ? nil : Decimal(string: targetPriceText)
        let fragranceID = chosenFragrance?.id
        let text = chosenFragrance == nil ? freeText.nilIfBlank : nil

        do {
            if let id = editingID {
                try await repo.update(
                    id: id, fragranceID: fragranceID, freeText: text,
                    stage: stage, targetPrice: price, notes: notes.nilIfBlank
                )
            } else {
                _ = try await repo.create(
                    fragranceID: fragranceID, freeText: text,
                    stage: stage, targetPrice: price, notes: notes.nilIfBlank
                )
            }
            return true
        } catch {
            errorMessage = "Couldn't save. Please try again."
            return false
        }
    }
}

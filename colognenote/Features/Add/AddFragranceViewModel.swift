import Foundation
import Observation
import SwiftUI

/// Backs the two-step Add / Edit flow (tasks 2.4–2.6).
@Observable
@MainActor
final class AddFragranceViewModel {

    enum Step { case find, details }

    // Which item we're editing, if any.
    let editingItemID: UUID?
    /// Set when this add came from "Buy it" on a wishlist row — deleted on save.
    let sourceWishlistItemID: UUID?
    var step: Step

    // Step 1 — find it
    var query = ""
    private(set) var results: [Fragrance] = []
    private(set) var isSearching = false
    var showManualEntry = false
    var manualName = ""
    var manualHouse = ""
    var manualConcentration: Concentration = .edt
    private(set) var selectedFragrance: Fragrance?

    // Step 2 — your details
    var priceText = ""
    var sizeText = ""
    var purchaseDate = Date()
    var includePurchaseDate = false
    var purchaseLocation = ""
    var batchCode = ""
    var rating: Int = 0
    var pickedImageData: Data?

    var isSaving = false
    var errorMessage: String?

    private let fragranceRepo = FragranceRepository()
    private let collectionRepo = CollectionRepository()
    private let wishlistRepo = WishlistRepository()
    private let storage = StorageService()
    private var searchTask: Task<Void, Never>?

    var isEditing: Bool { editingItemID != nil }
    var title: String { isEditing ? "Edit bottle" : "Add fragrance" }

    var canSave: Bool {
        guard !isSaving, selectedFragrance != nil else { return false }
        if !priceText.isEmpty, Decimal(string: priceText) == nil { return false }
        if !sizeText.isEmpty, Int(sizeText) == nil { return false }
        return true
    }

    init(editing item: CollectionItemRow? = nil, cost: CollectionItemCost? = nil) {
        sourceWishlistItemID = nil
        if let item {
            editingItemID = item.id
            step = .details
            selectedFragrance = item.fragrance
            priceText = cost.map { "\($0.price)" } ?? ""
            sizeText = item.sizeMl.map(String.init) ?? ""
            if let date = item.purchaseDate, let parsed = ISODate.date(from: date) {
                purchaseDate = parsed
                includePurchaseDate = true
            }
            purchaseLocation = item.purchaseLocation ?? ""
            batchCode = item.batchCode ?? ""
            rating = item.personalRating ?? 0
        } else {
            editingItemID = nil
            step = .find
        }
    }

    /// "Buy it" from a wishlist row.
    init(fromWishlist row: WishlistRow) {
        editingItemID = nil
        sourceWishlistItemID = row.id
        if let fragrance = row.fragrance {
            selectedFragrance = fragrance
            step = .details
        } else {
            manualName = row.fragranceFreetext ?? ""
            showManualEntry = true
            step = .find
        }
    }

    // MARK: Step 1

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
        selectedFragrance = fragrance
        step = .details
    }

    func createManualAndContinue() async {
        let name = manualName.trimmed
        guard !name.isEmpty else { errorMessage = "Give the fragrance a name."; return }
        do {
            let created = try await fragranceRepo.createPersonal(
                name: name,
                house: manualHouse.nilIfBlank,
                concentration: manualConcentration
            )
            selectedFragrance = created
            step = .details
        } catch {
            errorMessage = "Couldn't create that entry. Please try again."
        }
    }

    // MARK: Step 2

    /// - Returns: true on success so the caller can dismiss + refresh.
    func save() async -> Bool {
        guard let fragrance = selectedFragrance else { return false }
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        let price = priceText.isEmpty ? nil : Decimal(string: priceText)
        let size = sizeText.isEmpty ? nil : Int(sizeText)
        let dateString = includePurchaseDate ? ISODate.string(from: purchaseDate) : nil

        do {
            var photoPath: String?
            if let data = pickedImageData {
                photoPath = try await storage.upload(
                    data, to: .bottlePhotos, filename: "bottle-\(Int(Date().timeIntervalSince1970)).jpg"
                )
            }

            if let id = editingItemID {
                try await collectionRepo.update(
                    id: id,
                    sizeMl: size,
                    purchaseDate: dateString,
                    purchaseLocation: purchaseLocation.nilIfBlank,
                    batchCode: batchCode.nilIfBlank,
                    personalRating: rating == 0 ? nil : rating
                )
                if let price { try await collectionRepo.setCost(itemID: id, price: price) }
            } else {
                try await collectionRepo.create(
                    fragranceID: fragrance.id,
                    sizeMl: size,
                    purchaseDate: dateString,
                    purchaseLocation: purchaseLocation.nilIfBlank,
                    batchCode: batchCode.nilIfBlank,
                    personalRating: rating == 0 ? nil : rating,
                    fillLevel: 100,
                    photoUrl: photoPath,
                    price: price
                )
                if let wishlistID = sourceWishlistItemID {
                    try? await wishlistRepo.delete(id: wishlistID)
                }
            }
            return true
        } catch {
            errorMessage = "Couldn't save. \(String(describing: error).contains("one_active") ? "You already have this fragrance active in your collection." : "Please try again.")"
            return false
        }
    }
}

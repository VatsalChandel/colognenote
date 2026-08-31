import Foundation
import Supabase

/// A collection item with its fragrance embedded — the shape the grid and detail use.
struct CollectionItemRow: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let userId: UUID
    let fragranceId: UUID
    var sizeMl: Int?
    var purchaseDate: String?
    var purchaseLocation: String?
    var batchCode: String?
    var fillLevel: Int?
    var personalRating: Int?
    var status: ItemStatus
    var photoUrl: String?
    var createdAt: Date?
    var fragrance: Fragrance
}

struct CollectionRepository {

    // MARK: Reads (RLS scopes every row to the caller)

    func activeItems() async throws -> [CollectionItemRow] {
        try await supabase
            .from(Table.collectionItems)
            .select("*, fragrance:fragrances(*)")
            .eq("status", value: ItemStatus.active.rawValue)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func allItems() async throws -> [CollectionItemRow] {
        try await supabase
            .from(Table.collectionItems)
            .select("*, fragrance:fragrances(*)")
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func item(id: UUID) async throws -> CollectionItemRow {
        try await supabase
            .from(Table.collectionItems)
            .select("*, fragrance:fragrances(*)")
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    /// Owner-only collection value for active items (the `my_collection_value` view). **[PRIVATE]**
    func collectionValue() async throws -> CollectionValue? {
        let rows: [CollectionValue] = try await supabase
            .from(Table.myCollectionValue)
            .select()
            .execute()
            .value
        return rows.first
    }

    // MARK: Cost (isolated, owner-only table) **[PRIVATE]**

    func cost(itemID: UUID) async throws -> CollectionItemCost? {
        let rows: [CollectionItemCost] = try await supabase
            .from(Table.collectionItemCosts)
            .select()
            .eq("collection_item_id", value: itemID)
            .execute()
            .value
        return rows.first
    }

    // MARK: Writes

    /// Create the item and (optionally) its private cost row. Returns the new item id.
    @discardableResult
    func create(
        fragranceID: UUID,
        sizeMl: Int?,
        purchaseDate: String?,
        purchaseLocation: String?,
        batchCode: String?,
        personalRating: Int?,
        fillLevel: Int?,
        photoUrl: String?,
        price: Decimal?,
        currency: String = "USD"
    ) async throws -> UUID {
        let userID = try currentUserID()
        let newItem = NewItem(
            userId: userID,
            fragranceId: fragranceID,
            sizeMl: sizeMl,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            batchCode: batchCode,
            personalRating: personalRating,
            fillLevel: fillLevel,
            photoUrl: photoUrl
        )
        let created: CollectionItem = try await supabase
            .from(Table.collectionItems)
            .insert(newItem, returning: .representation)
            .select()
            .single()
            .execute()
            .value

        if let price {
            let cost = NewCost(
                collectionItemId: created.id,
                userId: userID,
                price: price,
                currency: currency
            )
            try await supabase
                .from(Table.collectionItemCosts)
                .insert(cost)
                .execute()
        }
        return created.id
    }

    func update(
        id: UUID,
        sizeMl: Int?,
        purchaseDate: String?,
        purchaseLocation: String?,
        batchCode: String?,
        personalRating: Int?
    ) async throws {
        let patch = ItemPatch(
            sizeMl: sizeMl,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            batchCode: batchCode,
            personalRating: personalRating
        )
        try await supabase
            .from(Table.collectionItems)
            .update(patch)
            .eq("id", value: id)
            .execute()
    }

    func setStatus(id: UUID, _ status: ItemStatus) async throws {
        try await supabase
            .from(Table.collectionItems)
            .update(["status": status.rawValue])
            .eq("id", value: id)
            .execute()
    }

    func setFillLevel(id: UUID, _ percent: Int) async throws {
        try await supabase
            .from(Table.collectionItems)
            .update(["fill_level": max(0, min(100, percent))])
            .eq("id", value: id)
            .execute()
    }

    /// Upsert the private cost row.
    func setCost(itemID: UUID, price: Decimal, currency: String = "USD") async throws {
        let cost = NewCost(
            collectionItemId: itemID,
            userId: try currentUserID(),
            price: price,
            currency: currency
        )
        try await supabase
            .from(Table.collectionItemCosts)
            .upsert(cost, onConflict: "collection_item_id")
            .execute()
    }

    /// Hard delete — the added-by-mistake case only. Cost row cascades.
    func delete(id: UUID) async throws {
        try await supabase
            .from(Table.collectionItems)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // MARK: Payloads

    private struct NewItem: Encodable {
        let userId: UUID
        let fragranceId: UUID
        let sizeMl: Int?
        let purchaseDate: String?
        let purchaseLocation: String?
        let batchCode: String?
        let personalRating: Int?
        let fillLevel: Int?
        let photoUrl: String?
    }

    private struct NewCost: Encodable {
        let collectionItemId: UUID
        let userId: UUID
        let price: Decimal
        let currency: String
    }

    private struct ItemPatch: Encodable {
        let sizeMl: Int?
        let purchaseDate: String?
        let purchaseLocation: String?
        let batchCode: String?
        let personalRating: Int?
    }
}

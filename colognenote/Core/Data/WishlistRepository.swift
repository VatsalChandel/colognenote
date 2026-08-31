import Foundation
import Supabase

struct WishlistRepository {

    func items() async throws -> [WishlistItem] {
        try await supabase
            .from(Table.wishlistItems)
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    @discardableResult
    func create(
        fragranceID: UUID?,
        freeText: String?,
        stage: WishlistStage,
        targetPrice: Decimal?,
        notes: String?
    ) async throws -> WishlistItem {
        let payload = NewWishlistItem(
            userId: try currentUserID(),
            fragranceId: fragranceID,
            fragranceFreetext: freeText,
            stage: stage,
            targetPrice: targetPrice,
            notes: notes
        )
        return try await supabase
            .from(Table.wishlistItems)
            .insert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func update(
        id: UUID,
        stage: WishlistStage? = nil,
        targetPrice: Decimal? = nil,
        notes: String? = nil
    ) async throws {
        let patch = WishlistPatch(stage: stage, targetPrice: targetPrice, notes: notes)
        try await supabase
            .from(Table.wishlistItems)
            .update(patch)
            .eq("id", value: id)
            .execute()
    }

    func setStage(id: UUID, _ stage: WishlistStage) async throws {
        try await supabase
            .from(Table.wishlistItems)
            .update(["stage": stage.rawValue])
            .eq("id", value: id)
            .execute()
    }

    func delete(id: UUID) async throws {
        try await supabase
            .from(Table.wishlistItems)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    private struct NewWishlistItem: Encodable {
        let userId: UUID
        let fragranceId: UUID?
        let fragranceFreetext: String?
        let stage: WishlistStage
        let targetPrice: Decimal?
        let notes: String?
    }

    private struct WishlistPatch: Encodable {
        let stage: WishlistStage?
        let targetPrice: Decimal?
        let notes: String?
    }
}

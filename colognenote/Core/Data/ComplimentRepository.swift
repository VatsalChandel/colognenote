import Foundation
import Supabase

struct ComplimentRepository {

    func compliments(itemID: UUID) async throws -> [Compliment] {
        try await supabase
            .from(Table.compliments)
            .select()
            .eq("collection_item_id", value: itemID)
            .order("complimented_on", ascending: false)
            .execute()
            .value
    }

    func complimentCount(itemID: UUID) async throws -> Int {
        let count = try await supabase
            .from(Table.compliments)
            .select("id", head: true, count: .exact)
            .eq("collection_item_id", value: itemID)
            .execute()
            .count
        return count ?? 0
    }

    @discardableResult
    func create(
        itemID: UUID,
        wearLogID: UUID?,
        complimentedOn: String,
        who: String?,
        comment: String?
    ) async throws -> Compliment {
        let payload = NewCompliment(
            userId: try currentUserID(),
            collectionItemId: itemID,
            wearLogId: wearLogID,
            complimentedOn: complimentedOn,
            who: who,
            comment: comment
        )
        return try await supabase
            .from(Table.compliments)
            .insert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    func delete(id: UUID) async throws {
        try await supabase
            .from(Table.compliments)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    private struct NewCompliment: Encodable {
        let userId: UUID
        let collectionItemId: UUID
        let wearLogId: UUID?
        let complimentedOn: String
        let who: String?
        let comment: String?
    }
}

import Foundation
import Supabase

struct WearLogRepository {

    func wears(itemID: UUID) async throws -> [WearLog] {
        try await supabase
            .from(Table.wearLogs)
            .select()
            .eq("collection_item_id", value: itemID)
            .order("worn_on", ascending: false)
            .execute()
            .value
    }

    /// Short list for the "attach to a recent wear" picker on the compliment sheet.
    func recentWears(itemID: UUID, limit: Int = 5) async throws -> [WearLog] {
        try await supabase
            .from(Table.wearLogs)
            .select()
            .eq("collection_item_id", value: itemID)
            .order("worn_on", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func wearCount(itemID: UUID) async throws -> Int {
        let count = try await supabase
            .from(Table.wearLogs)
            .select("id", head: true, count: .exact)
            .eq("collection_item_id", value: itemID)
            .execute()
            .count
        return count ?? 0
    }

    @discardableResult
    func create(
        itemID: UUID,
        wornOn: String,
        occasion: Occasion?,
        weatherTemp: Double?,
        weatherCondition: String?,
        isSotd: Bool,
        pairing: String?
    ) async throws -> WearLog {
        let payload = NewWear(
            userId: try currentUserID(),
            collectionItemId: itemID,
            wornOn: wornOn,
            occasion: occasion,
            weatherTemp: weatherTemp,
            weatherCondition: weatherCondition,
            isSotd: isSotd,
            pairing: pairing
        )
        return try await supabase
            .from(Table.wearLogs)
            .insert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    /// Delete-only (no in-place edit). Any attached compliment goes loose via
    /// `wear_log_id ON DELETE SET NULL`.
    func delete(id: UUID) async throws {
        try await supabase
            .from(Table.wearLogs)
            .delete()
            .eq("id", value: id)
            .execute()
    }

    private struct NewWear: Encodable {
        let userId: UUID
        let collectionItemId: UUID
        let wornOn: String
        let occasion: Occasion?
        let weatherTemp: Double?
        let weatherCondition: String?
        let isSotd: Bool
        let pairing: String?
    }
}

import Foundation
import Supabase

/// One note of a fragrance's pyramid, joined to its display name and accord family.
/// Shape of the `fragrance_notes` embed used on the detail screen.
struct FragranceNoteDetail: Codable, Hashable, Sendable {
    let position: PyramidPosition
    let note: NoteRef

    struct NoteRef: Codable, Hashable, Sendable {
        let name: String
        let familyId: Int
    }
}

/// Canonical + personal fragrance records.
struct FragranceRepository {

    /// Add-flow search: verified canonical fragrances matching name or house.
    /// RLS already limits reads to `tier = canonical AND status = verified`.
    func searchCanonical(_ query: String, limit: Int = 25) async throws -> [Fragrance] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let pattern = "%\(trimmed)%"
        return try await supabase
            .from(Table.fragrances)
            .select()
            .or("name.ilike.\(pattern),house.ilike.\(pattern)")
            .order("name")
            .limit(limit)
            .execute()
            .value
    }

    func fragrance(id: UUID) async throws -> Fragrance {
        try await supabase
            .from(Table.fragrances)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    /// Pyramid for the detail screen. Empty for accords-only fragrances — the UI
    /// hides the pyramid and shows accords in that case.
    func notes(fragranceID: UUID) async throws -> [FragranceNoteDetail] {
        try await supabase
            .from(Table.fragranceNotes)
            .select("position, note:notes(name, family_id)")
            .eq("fragrance_id", value: fragranceID)
            .execute()
            .value
    }

    /// A fragrance's accords, derived from its notes' families (the `fragrance_accords` view).
    func accords(fragranceID: UUID) async throws -> [FragranceAccord] {
        try await supabase
            .from(Table.fragranceAccords)
            .select()
            .eq("fragrance_id", value: fragranceID)
            .execute()
            .value
    }

    /// "Add it manually" path — creates a `personal` / `pending` fragrance owned by the caller.
    func createPersonal(
        name: String,
        house: String?,
        concentration: Concentration?
    ) async throws -> Fragrance {
        let payload = NewPersonalFragrance(
            name: name,
            house: house,
            concentration: concentration,
            tier: .personal,
            status: .pending,
            submittedBy: try currentUserID()
        )
        return try await supabase
            .from(Table.fragrances)
            .insert(payload, returning: .representation)
            .select()
            .single()
            .execute()
            .value
    }

    private struct NewPersonalFragrance: Encodable {
        let name: String
        let house: String?
        let concentration: Concentration?
        let tier: FragranceTier
        let status: FragranceStatus
        let submittedBy: UUID
    }
}

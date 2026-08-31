import Foundation
import Supabase

/// Reference data: the accord families and the note pick-list. World-readable,
/// so these work signed-in or not.
struct CatalogRepository {

    func accordFamilies() async throws -> [AccordFamily] {
        try await supabase
            .from(Table.accordFamilies)
            .select()
            .order("id")
            .execute()
            .value
    }

    func notes() async throws -> [Note] {
        try await supabase
            .from(Table.notes)
            .select()
            .order("name")
            .execute()
            .value
    }
}

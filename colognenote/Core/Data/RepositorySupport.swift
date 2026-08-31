import Foundation
import Supabase

/// Errors surfaced by the data layer.
enum RepositoryError: LocalizedError {
    case notAuthenticated
    case notFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: "You need to be signed in to do that."
        case .notFound:         "That item could no longer be found."
        }
    }
}

/// The signed-in user's id, required for insert payloads whose RLS `WITH CHECK`
/// clause is `user_id = auth.uid()`. Reads don't need this — RLS scopes them.
func currentUserID() throws -> UUID {
    guard let id = supabase.auth.currentUser?.id else {
        throw RepositoryError.notAuthenticated
    }
    return id
}

// Table name constants — one place to change if the schema ever renames.
enum Table {
    static let profiles = "profiles"
    static let accordFamilies = "accord_families"
    static let notes = "notes"
    static let fragrances = "fragrances"
    static let fragranceNotes = "fragrance_notes"
    static let fragranceAccords = "fragrance_accords"
    static let collectionItems = "collection_items"
    static let collectionItemCosts = "collection_item_costs"
    static let myCollectionValue = "my_collection_value"
    static let wearLogs = "wear_logs"
    static let compliments = "compliments"
    static let follows = "follows"
    static let wishlistItems = "wishlist_items"
}

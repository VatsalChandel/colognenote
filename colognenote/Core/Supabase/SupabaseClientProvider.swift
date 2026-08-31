import Foundation
import Supabase

/// App-wide Supabase client.
///
/// Configured with the anon key only, so every query is subject to Row-Level Security
/// and runs as the currently signed-in user (or anonymously for world-readable tables
/// like `accord_families`).
let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey,
    options: .init(
        db: .init(encoder: .cologne, decoder: .cologne)
    )
)

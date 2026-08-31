import Foundation
import OSLog
import Supabase

/// DEBUG-only startup check: confirms the Supabase client is configured, the network
/// path works, and models decode. Hits `accord_families` (world-readable, no auth).
/// Remove once real screens exercise the data layer.
enum ConnectivityProbe {
    private static let log = Logger(subsystem: "vatsal.colognenote", category: "probe")

    static func run() async {
        #if DEBUG
        log.info("Supabase host: \(SupabaseConfig.url.absoluteString, privacy: .public)")
        do {
            let families: [AccordFamily] = try await supabase
                .from(Table.accordFamilies)
                .select()
                .order("id")
                .execute()
                .value
            let names = families.prefix(3).map(\.name).joined(separator: ", ")
            log.info("✅ Supabase OK — decoded \(families.count, privacy: .public) accord families: \(names, privacy: .public)…")
        } catch {
            log.error("❌ Supabase connectivity probe failed: \(String(describing: error), privacy: .public)")
        }
        #endif
    }
}

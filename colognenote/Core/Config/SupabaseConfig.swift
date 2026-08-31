import Foundation

/// Supabase connection values, injected at build time.
///
/// Flow: `Secrets.xcconfig` (git-ignored) → `Config.xcconfig` → generated Info.plist → here.
/// Only the anon / public key is ever used; every request runs as the signed-in user
/// under Row-Level Security. See `Secrets.example.xcconfig` for setup.
enum SupabaseConfig {

    /// Supabase project ref, e.g. `abcdefghijklmnop`.
    static let projectRef = infoValue(for: "SUPABASE_PROJECT_REF")

    /// Anon / public API key (a JWT). Safe to ship in the app binary.
    static let anonKey = infoValue(for: "SUPABASE_ANON_KEY")

    /// Base project URL — `https://<ref>.supabase.co`. No path suffix; the SDK appends its own.
    static let url: URL = {
        guard let url = URL(string: "https://\(projectRef).supabase.co") else {
            fatalError("SupabaseConfig: invalid project ref '\(projectRef)'")
        }
        return url
    }()

    private static func infoValue(for key: String) -> String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty,
            !value.hasPrefix("your-")
        else {
            fatalError(
                """
                Missing build setting \(key).
                Copy Secrets.example.xcconfig → Secrets.xcconfig and fill in your \
                Supabase project ref and anon key (Supabase dashboard → Settings → API).
                """
            )
        }
        return value
    }
}

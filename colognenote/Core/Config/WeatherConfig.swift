import Foundation

/// OpenWeather API key, injected the same way as the Supabase values.
/// Optional — `apiKey` is nil when no key is set, and weather capture is skipped.
enum WeatherConfig {
    static var apiKey: String? {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
            !raw.trimmingCharacters(in: .whitespaces).isEmpty,
            !raw.hasPrefix("$(")   // unresolved build setting on a fresh clone
        else { return nil }
        return raw
    }
}

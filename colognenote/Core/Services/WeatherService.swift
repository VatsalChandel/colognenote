import CoreLocation
import Foundation

/// Fetches current weather at log time. The result is snapshotted onto the
/// WearLog and never re-fetched (blueprint §4). Returns nil on any failure —
/// no key, no network, bad response — and the wear just logs without weather.
struct WeatherService {

    struct Reading: Sendable {
        /// °C, one decimal — fits `wear_logs.weather_temp numeric(4,1)`.
        let temperature: Double
        /// Short condition word, e.g. "clear", "rain", "clouds".
        let condition: String
    }

    func reading(at coordinate: CLLocationCoordinate2D) async -> Reading? {
        guard let key = WeatherConfig.apiKey else { return nil }

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: key),
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let payload = try JSONDecoder().decode(Payload.self, from: data)
            return Reading(
                temperature: (payload.main.temp * 10).rounded() / 10,
                condition: payload.weather.first?.main.lowercased() ?? "unknown"
            )
        } catch {
            return nil
        }
    }

    private struct Payload: Decodable {
        struct Main: Decodable { let temp: Double }
        struct Weather: Decodable { let main: String }
        let main: Main
        let weather: [Weather]
    }
}

import Foundation
import Observation

/// Backs the fast Log-wear sheet (task 3.1). Weather is captured once on appear
/// and snapshotted onto the WearLog.
@Observable
@MainActor
final class LogWearViewModel {

    enum WeatherState: Equatable { case idle, loading, ready, unavailable }

    let itemID: UUID
    var date = Date()
    var occasion: Occasion?
    var isSotd = false
    var pairing = ""

    private(set) var weather: WeatherService.Reading?
    private(set) var weatherState: WeatherState = .idle
    var isSaving = false
    var errorMessage: String?

    private let wearRepo = WearLogRepository()
    private let location = LocationProvider()
    private let weatherService = WeatherService()

    init(itemID: UUID) { self.itemID = itemID }

    var weatherSummary: String {
        switch weatherState {
        case .idle, .loading: "Checking the weather…"
        case .unavailable:    "Weather unavailable — logging without it"
        case .ready:
            weather.map { "\(Int($0.temperature.rounded()))°C · \($0.condition.capitalized)" }
                ?? "Weather unavailable"
        }
    }

    func captureWeather() async {
        guard weatherState == .idle else { return }
        weatherState = .loading
        guard
            let coordinate = await location.currentCoordinate(),
            let reading = await weatherService.reading(at: coordinate)
        else {
            weatherState = .unavailable
            return
        }
        weather = reading
        weatherState = .ready
    }

    /// - Returns: true on success.
    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await wearRepo.create(
                itemID: itemID,
                wornOn: Self.dateFormatter.string(from: date),
                occasion: occasion,
                weatherTemp: weather?.temperature,
                weatherCondition: weather?.condition,
                isSotd: isSotd,
                pairing: pairing.nilIfBlank
            )
            return true
        } catch {
            errorMessage = "Couldn't save that wear. Please try again."
            return false
        }
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

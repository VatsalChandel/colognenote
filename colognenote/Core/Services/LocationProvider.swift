import CoreLocation

/// One-shot current-location lookup for weather capture at log time.
/// Everything here degrades to `nil` — permission denied, a slow fix, no
/// hardware — so logging a wear is never blocked (task 3.6).
@MainActor
final class LocationProvider: NSObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var fixContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    /// Requests permission if needed, then a single fix. Times out after 8s.
    func currentCoordinate() async -> CLLocationCoordinate2D? {
        var status = manager.authorizationStatus
        if status == .notDetermined {
            status = await withCheckedContinuation { continuation in
                authContinuation = continuation
                manager.requestWhenInUseAuthorization()
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(30))
                    authContinuation?.resume(returning: manager.authorizationStatus)
                    authContinuation = nil
                }
            }
        }
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return nil }

        return await withCheckedContinuation { continuation in
            fixContinuation = continuation
            manager.requestLocation()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(8))
                resumeFix(nil)
            }
        }
    }

    private func resumeFix(_ coordinate: CLLocationCoordinate2D?) {
        fixContinuation?.resume(returning: coordinate)
        fixContinuation = nil
    }

    // MARK: CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            // This fires once with `.notDetermined` right after requesting — wait
            // for the user's actual decision before resuming.
            guard status != .notDetermined else { return }
            authContinuation?.resume(returning: status)
            authContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last?.coordinate
        Task { @MainActor in resumeFix(coordinate) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in resumeFix(nil) }
    }
}

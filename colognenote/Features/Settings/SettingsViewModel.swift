import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {

    enum State: Equatable { case loading, ready, failed(String) }

    private(set) var state: State = .loading
    private(set) var profile: Profile?
    var isBusy = false
    var errorMessage: String?

    private let profiles = ProfileRepository()

    func load() async {
        do {
            profile = try await profiles.currentProfile()
            state = .ready
        } catch {
            state = .failed("Couldn't load your settings.")
        }
    }

    func setShowCollectionValue(_ on: Bool) async {
        guard profile?.showCollectionValue != on else { return }
        do {
            profile = try await profiles.update(showCollectionValue: on)
        } catch {
            errorMessage = "Couldn't update that setting."
        }
    }

    /// Deletes the account (cascades everything), then signs out.
    func deleteAccount(then signOut: () async -> Void) async {
        errorMessage = nil
        isBusy = true
        defer { isBusy = false }
        do {
            try await profiles.deleteAccount()
            await signOut()
        } catch {
            errorMessage = "Couldn't delete your account. Please try again."
        }
    }
}

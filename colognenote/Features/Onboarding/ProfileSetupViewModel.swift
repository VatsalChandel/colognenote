import Foundation
import Observation
import SwiftUI
import Supabase

/// Backs ``ProfileSetupView`` — the first-run screen that turns the trigger's
/// stub profile into a real one (task 1.4).
@Observable
@MainActor
final class ProfileSetupViewModel {

    enum UsernameStatus: Equatable {
        case empty, invalid(String), checking, available, taken

        var hint: String? {
            switch self {
            case .empty, .checking, .available: nil
            case .invalid(let why): why
            case .taken: "That username is taken."
            }
        }
    }

    var username = ""
    var displayName = ""
    var pickedImageData: Data?
    var usernameStatus: UsernameStatus = .empty
    var isSaving = false
    var errorMessage: String?

    private let profiles = ProfileRepository()
    private let storage = StorageService()

    init() {
        // Prefill display name from the value captured at sign-up.
        if let name = supabase.auth.currentUser?.userMetadata["display_name"]?.stringValue {
            displayName = name
        }
    }

    var canSave: Bool {
        !isSaving && usernameStatus == .available && !displayName.trimmed.isEmpty
    }

    /// Local rules first; returns false if the candidate can't possibly be valid.
    func validateLocally() -> Bool {
        let name = username.trimmed
        if name.isEmpty { usernameStatus = .empty; return false }
        if name.count < 3 || name.count > 20 {
            usernameStatus = .invalid("3–20 characters."); return false
        }
        if name.wholeMatch(of: #/[a-zA-Z0-9_]+/#) == nil {
            usernameStatus = .invalid("Letters, numbers and underscores only."); return false
        }
        if name.lowercased().hasPrefix(Profile.reservedUsernamePrefix) {
            usernameStatus = .invalid("Can't start with “\(Profile.reservedUsernamePrefix)”."); return false
        }
        return true
    }

    /// Debounced availability check — call from `.task(id: username)`.
    func checkAvailability() async {
        guard validateLocally() else { return }
        usernameStatus = .checking
        try? await Task.sleep(for: .milliseconds(400))
        if Task.isCancelled { return }
        do {
            let free = try await profiles.usernameAvailable(username.trimmed)
            usernameStatus = free ? .available : .taken
        } catch {
            // Network hiccup — don't block; the DB unique index is the real guard.
            usernameStatus = .available
        }
    }

    /// - Returns: true on success, so the caller can refresh the session.
    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        var avatarPath: String?
        if let data = pickedImageData {
            do {
                avatarPath = try await storage.upload(
                    data, to: .avatars, filename: "avatar-\(Int(Date().timeIntervalSince1970)).jpg"
                )
            } catch {
                errorMessage = "Couldn't upload that photo. You can add one later in Settings."
                return false
            }
        }

        do {
            _ = try await profiles.update(
                username: username.trimmed,
                displayName: displayName.trimmed,
                avatarUrl: avatarPath
            )
            return true
        } catch {
            errorMessage = "Couldn't save your profile. \(Self.saveHint(error))"
            return false
        }
    }

    private static func saveHint(_ error: Error) -> String {
        let text = String(describing: error).lowercased()
        if text.contains("duplicate") || text.contains("unique") {
            return "That username was just taken — try another."
        }
        return "Please try again."
    }
}

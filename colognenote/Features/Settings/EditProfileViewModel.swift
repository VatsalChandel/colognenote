import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class EditProfileViewModel {

    enum UsernameStatus: Equatable {
        case unchanged, invalid(String), checking, available, taken
        var problem: String? {
            switch self {
            case .invalid(let why): why
            case .taken: "That username is taken."
            default: nil
            }
        }
    }

    private let original: Profile

    var displayName: String
    var bio: String
    var username: String
    var pickedImageData: Data?
    private(set) var usernameStatus: UsernameStatus = .unchanged

    var isSaving = false
    var errorMessage: String?

    private let profiles = ProfileRepository()
    private let storage = StorageService()

    init(profile: Profile) {
        original = profile
        displayName = profile.displayName ?? ""
        bio = profile.bio ?? ""
        username = profile.username
    }

    var usernameChanged: Bool {
        username.trimmed.lowercased() != original.username.lowercased()
    }

    var canSave: Bool {
        guard !isSaving, !displayName.trimmed.isEmpty else { return false }
        if usernameChanged {
            return usernameStatus == .available
        }
        return true
    }

    func checkUsername() async {
        guard usernameChanged else { usernameStatus = .unchanged; return }
        let name = username.trimmed
        if name.count < 3 || name.count > 20 {
            usernameStatus = .invalid("3–20 characters."); return
        }
        if name.wholeMatch(of: #/[a-zA-Z0-9_]+/#) == nil {
            usernameStatus = .invalid("Letters, numbers and underscores only."); return
        }
        if name.lowercased().hasPrefix(Profile.reservedUsernamePrefix) {
            usernameStatus = .invalid("Can't start with “\(Profile.reservedUsernamePrefix)”."); return
        }
        usernameStatus = .checking
        try? await Task.sleep(for: .milliseconds(400))
        if Task.isCancelled { return }
        let free = (try? await profiles.usernameAvailable(name)) ?? true
        usernameStatus = free ? .available : .taken
    }

    /// - Returns: true on success.
    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        var avatarPath: String?
        if let data = pickedImageData {
            avatarPath = try? await storage.upload(
                data, to: .avatars, filename: "avatar-\(Int(Date().timeIntervalSince1970)).jpg"
            )
        }

        do {
            _ = try await profiles.update(
                username: usernameChanged ? username.trimmed : nil,
                displayName: displayName.trimmed,
                bio: bio.nilIfBlank,
                avatarUrl: avatarPath
            )
            return true
        } catch {
            errorMessage = "Couldn't save your profile. Please try again."
            return false
        }
    }
}

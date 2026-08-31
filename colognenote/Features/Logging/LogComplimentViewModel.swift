import Foundation
import Observation

/// Backs the fast Log-compliment sheet (task 3.3). Attach to a recent wear, or
/// leave it loose to attach later.
@Observable
@MainActor
final class LogComplimentViewModel {

    let itemID: UUID
    var date = Date()
    var who = ""
    var comment = ""
    var attachedWearID: UUID?

    private(set) var recentWears: [WearLog] = []
    var isSaving = false
    var errorMessage: String?

    private let wearRepo = WearLogRepository()
    private let complimentRepo = ComplimentRepository()

    init(itemID: UUID) { self.itemID = itemID }

    func loadRecentWears() async {
        recentWears = (try? await wearRepo.recentWears(itemID: itemID)) ?? []
    }

    func save() async -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await complimentRepo.create(
                itemID: itemID,
                wearLogID: attachedWearID,
                complimentedOn: ISODate.string(from: date),
                who: who.nilIfBlank,
                comment: comment.nilIfBlank
            )
            return true
        } catch {
            errorMessage = "Couldn't save that compliment. Please try again."
            return false
        }
    }
}

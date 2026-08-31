import SwiftUI

/// Placeholder for the fast "Log wear" sheet. Built in Milestone 3 (task 3.1).
struct LogWearView: View {
    let itemID: UUID
    var onLogged: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            EmptyStateView(
                systemImage: "drop.fill",
                title: "Log a wear",
                message: "The two-tap wear sheet arrives in Milestone 3."
            )
            .navigationTitle("Log wear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}

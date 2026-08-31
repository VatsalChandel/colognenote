import SwiftUI

/// Placeholder for the fast "Log compliment" sheet. Built in Milestone 3 (task 3.3).
struct LogComplimentView: View {
    let itemID: UUID
    var onLogged: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            EmptyStateView(
                systemImage: "hands.clap.fill",
                title: "Log a compliment",
                message: "The compliment sheet arrives in Milestone 3."
            )
            .navigationTitle("Log compliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}

import SwiftUI

/// Placeholder for the two-step Add flow (search canonical → your details).
/// Built in Milestone 2 (tasks 2.4–2.5).
struct AddFragranceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            EmptyStateView(
                systemImage: "plus.magnifyingglass",
                title: "Add a fragrance",
                message: "Search and add flow arrives in Milestone 2."
            )
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddFragranceView()
}

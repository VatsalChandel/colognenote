import SwiftUI

/// The shelf and the hub everything routes through. Real grid, sort/filter/search,
/// Add and Settings entry points arrive in Milestone 2.
struct CollectionView: View {
    var body: some View {
        EmptyStateView(
            systemImage: "square.grid.2x2",
            title: "Collection",
            message: "Your shelf will live here. Building it in Milestone 2."
        )
        .navigationTitle("Collection")
    }
}

#Preview {
    NavigationStack { CollectionView() }
}

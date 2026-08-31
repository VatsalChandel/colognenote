import SwiftUI

/// The sampling funnel — sampled → considering → want full bottle. Built in Milestone 5.
struct WishlistView: View {
    var body: some View {
        EmptyStateView(
            systemImage: "heart",
            title: "Wishlist",
            message: "Track what you're sampling and considering here."
        )
        .navigationTitle("Wishlist")
    }
}

#Preview {
    NavigationStack { WishlistView() }
}

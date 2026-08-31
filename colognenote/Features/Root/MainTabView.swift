import SwiftUI

/// The app shell: three tabs. Settings and Add are not tabs — they live on the
/// Collection nav bar (added with the real Collection screen in Milestone 2).
struct MainTabView: View {
    enum Tab: Hashable { case collection, insights, wishlist }
    @State private var selection: Tab = .collection

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                CollectionView()
            }
            .tabItem { Label("Collection", systemImage: "square.grid.2x2") }
            .tag(Tab.collection)

            NavigationStack {
                InsightsView()
            }
            .tabItem { Label("Insights", systemImage: "chart.bar") }
            .tag(Tab.insights)

            NavigationStack {
                WishlistView()
            }
            .tabItem { Label("Wishlist", systemImage: "heart") }
            .tag(Tab.wishlist)
        }
    }
}

#Preview {
    MainTabView().environment(SessionStore())
}

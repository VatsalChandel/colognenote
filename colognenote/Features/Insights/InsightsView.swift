import SwiftUI

/// The payoff screen — most-worn, cost-per-wear, accord breakdown, wardrobe gaps.
/// All **[PRIVATE]**. Built in Milestone 4.
struct InsightsView: View {
    var body: some View {
        EmptyStateView(
            systemImage: "chart.bar",
            title: "Insights",
            message: "Once you've logged some wears, this is where the stats show up."
        )
        .navigationTitle("Insights")
    }
}

#Preview {
    NavigationStack { InsightsView() }
}

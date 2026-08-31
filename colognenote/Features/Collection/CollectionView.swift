import SwiftUI

/// The shelf and the hub everything routes through. Milestone 1 delivers the load
/// states and the empty state (1.5); sort / filter / search / long-press land in M2.
struct CollectionView: View {
    @Environment(SessionStore.self) private var session
    @State private var model = CollectionViewModel()
    @State private var showAdd = false
    @State private var showSettings = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                LoadingView(label: "Loading your shelf…")
            case .failed(let message):
                ErrorView(message: message) { Task { await model.load() } }
            case .empty:
                emptyState
            case .loaded(let items):
                grid(items)
            }
        }
        .navigationTitle("Collection")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { AddFragranceView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private var emptyState: some View {
        ZStack {
            ScrollView { SampleShelfBackdrop() }
                .disabled(true)
            EmptyStateView(
                systemImage: "drop.halffull",
                title: "Your shelf is empty",
                message: "Add your first fragrance to start tracking wears and compliments.",
                actionTitle: "Add your first fragrance",
                action: { showAdd = true }
            )
        }
    }

    private func grid(_ items: [CollectionItemRow]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.lg) {
                ForEach(items) { item in
                    BottleCard(item: item)
                }
            }
            .padding(Theme.Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack { CollectionView() }
        .environment(SessionStore())
}

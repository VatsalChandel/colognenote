import SwiftUI

/// The shelf and the hub everything routes through (screen spec #2).
struct CollectionView: View {
    @State private var model = CollectionViewModel()
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var quickLog: QuickLog?

    private enum QuickLog: Identifiable, Hashable {
        case wear(UUID), compliment(UUID)
        var id: Self { self }
    }

    private let columns = [GridItem(.flexible(), spacing: Theme.Spacing.lg),
                           GridItem(.flexible(), spacing: Theme.Spacing.lg)]

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                LoadingView(label: "Loading your shelf…")
            case .failed(let message):
                ErrorView(message: message) { Task { await model.load() } }
            case .empty:
                emptyState
            case .ready:
                content
            }
        }
        .navigationTitle("Collection")
        .navigationDestination(for: UUID.self) { itemID in
            BottleDetailView(itemID: itemID)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if model.state == .ready { sortFilterMenu }
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd, onDismiss: { Task { await model.load() } }) {
            AddFragranceView()
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(item: $quickLog) { which in
            switch which {
            case .wear(let id):
                LogWearView(itemID: id) { Task { await model.load() } }
            case .compliment(let id):
                LogComplimentView(itemID: id) { Task { await model.load() } }
            }
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    // MARK: Populated

    private var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.lg) {
                ForEach(model.displayedItems) { item in
                    NavigationLink(value: item.row.id) {
                        BottleCard(item: item.row)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button { quickLog = .wear(item.row.id) } label: {
                            Label("Log wear", systemImage: "drop.fill")
                        }
                        Button { quickLog = .compliment(item.row.id) } label: {
                            Label("Log compliment", systemImage: "hands.clap.fill")
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)

            if model.displayedItems.isEmpty {
                EmptyStateView(
                    systemImage: "line.3.horizontal.decrease.circle",
                    title: "Nothing matches",
                    message: "No bottles fit the current search and filters."
                )
                .frame(minHeight: 240)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .searchable(text: $model.searchText, prompt: "Search your shelf")
    }

    private var header: some View {
        HStack {
            Text(pluralized(model.value?.itemCount ?? model.allItems.count, "bottle"))
                .font(.subheadline.weight(.semibold))
            if let total = model.value?.totalValue {
                Text("· \(total.formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
            Spacer()
            if model.filter.isNarrowed || !model.searchText.isEmpty {
                Text("\(model.displayedItems.count) shown")
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .background(.bar)
    }

    private var sortFilterMenu: some View {
        Menu {
            Picker("Sort", selection: $model.sort) {
                ForEach(CollectionSort.allCases) { Text($0.rawValue).tag($0) }
            }
            Divider()
            Menu("Status") {
                Picker("Status", selection: $model.filter.status) {
                    Text("Active").tag(ItemStatus?.some(.active))
                    Text("Finished").tag(ItemStatus?.some(.finished))
                    Text("Sold").tag(ItemStatus?.some(.sold))
                    Text("All").tag(ItemStatus?.none)
                }
            }
            if !model.houseOptions.isEmpty {
                Menu("House") {
                    Picker("House", selection: $model.filter.house) {
                        Text("Any").tag(String?.none)
                        ForEach(model.houseOptions, id: \.self) { Text($0).tag(String?.some($0)) }
                    }
                }
            }
            if !model.accordOptions.isEmpty {
                Menu("Accord") {
                    Picker("Accord", selection: $model.filter.accord) {
                        Text("Any").tag(String?.none)
                        ForEach(model.accordOptions, id: \.self) { Text($0).tag(String?.some($0)) }
                    }
                }
            }
        } label: {
            Image(systemName: model.filter.isNarrowed
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
    }

    // MARK: Empty (owns nothing)

    private var emptyState: some View {
        ZStack {
            ScrollView { SampleShelfBackdrop() }.disabled(true)
            EmptyStateView(
                systemImage: "drop.halffull",
                title: "Your shelf is empty",
                message: "Add your first fragrance to start tracking wears and compliments.",
                actionTitle: "Add your first fragrance",
                action: { showAdd = true }
            )
        }
    }
}

#Preview {
    NavigationStack { CollectionView() }
        .environment(SessionStore())
}

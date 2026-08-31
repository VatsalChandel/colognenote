import SwiftUI

/// The sampling funnel — sampled → considering → want full bottle (screen spec #8).
struct WishlistView: View {
    @State private var model = WishlistViewModel()
    @State private var editing: EditTarget?
    @State private var converting: WishlistRow?

    private enum EditTarget: Identifiable {
        case new, existing(WishlistRow)
        var id: String {
            switch self {
            case .new: "new"
            case .existing(let row): row.id.uuidString
            }
        }
    }

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                LoadingView(label: "Loading your wishlist…")
            case .failed(let message):
                ErrorView(message: message) { Task { await model.load() } }
            case .empty:
                EmptyStateView(
                    systemImage: "heart",
                    title: "Nothing on the wishlist",
                    message: "Track what you're sampling and considering — and what you want a full bottle of.",
                    actionTitle: "Add something",
                    action: { editing = .new }
                )
            case .ready:
                list
            }
        }
        .navigationTitle("Wishlist")
        .toolbar {
            if model.state == .ready {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { editing = .new } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add to wishlist")
                }
            }
        }
        .sheet(item: $editing, onDismiss: { Task { await model.load() } }) { target in
            switch target {
            case .new:                 WishlistItemEditView()
            case .existing(let row):    WishlistItemEditView(editing: row)
            }
        }
        .sheet(item: $converting, onDismiss: { Task { await model.load() } }) { row in
            AddFragranceView(fromWishlist: row)
        }
        .task { await model.load() }
        .refreshable { await model.load() }
    }

    private var list: some View {
        List {
            ForEach(WishlistStage.allCases, id: \.self) { stage in
                let rows = model.rows(for: stage)
                if !rows.isEmpty {
                    Section(stage.label) {
                        ForEach(rows) { row in
                            Button { editing = .existing(row) } label: { rowView(row) }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .leading) {
                                    if stage == .wantBottle {
                                        Button { converting = row } label: {
                                            Label("Buy it", systemImage: "bag")
                                        }
                                        .tint(.green)
                                    } else if let next = stage.next {
                                        Button {
                                            Task { await model.setStage(row, to: next) }
                                        } label: {
                                            Label("To \(next.label)", systemImage: "arrow.right")
                                        }
                                        .tint(Theme.Palette.accent)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await model.delete(row) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }

    private func rowView(_ row: WishlistRow) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.displayName).font(.subheadline.weight(.medium))
                HStack(spacing: Theme.Spacing.sm) {
                    if let house = row.displayHouse, !house.isEmpty {
                        Text(house)
                    }
                    if let price = row.targetPrice {
                        Text("target \(price.formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                    }
                }
                .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                if let notes = row.notes, !notes.isEmpty {
                    Text(notes).font(.caption).foregroundStyle(Theme.Palette.tertiaryText).lineLimit(2)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { WishlistView() }
}

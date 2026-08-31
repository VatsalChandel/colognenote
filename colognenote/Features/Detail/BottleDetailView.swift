import SwiftUI

/// Everything about one owned bottle, and the launchpad for logging (screen spec #4).
struct BottleDetailView: View {
    let itemID: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var model: BottleDetailViewModel
    @State private var sheet: Sheet?
    @State private var confirmStatus: ItemStatus?
    @State private var confirmDeleteItem = false
    @State private var confirmDeleteWear: UUID?
    @State private var confirmDeleteCompliment: UUID?

    private enum Sheet: Identifiable, Hashable {
        case edit, logWear, logCompliment
        var id: Self { self }
    }

    init(itemID: UUID) {
        self.itemID = itemID
        _model = State(initialValue: BottleDetailViewModel(itemID: itemID))
    }

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                LoadingView()
            case .failed(let message):
                ErrorView(message: message) { Task { await model.load() } }
            case .deleted:
                Color.clear.onAppear { dismiss() }
            case .loaded:
                loaded
            }
        }
        .navigationTitle(model.item?.fragrance.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { if model.state == .loaded { menu } }
        .task { await model.load() }
        .sheet(item: $sheet) { which in
            switch which {
            case .edit:
                AddFragranceView(editing: model.item, cost: model.cost)
            case .logWear:
                LogWearView(itemID: itemID) { Task { await model.reload() } }
            case .logCompliment:
                LogComplimentView(itemID: itemID) { Task { await model.reload() } }
            }
        }
        .confirmationDialog("Change status?", isPresented: statusConfirmBinding, presenting: confirmStatus) { status in
            Button("Mark as \(status.rawValue)") { Task { await model.setStatus(status) } }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete this bottle?", isPresented: $confirmDeleteItem) {
            Button("Delete", role: .destructive) { Task { await model.deleteItem() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the bottle and its price. Wear and compliment history goes with it. Use “Finished” or “Sold” to keep the history.")
        }
        .confirmationDialog("Delete this wear?", isPresented: deleteWearBinding, presenting: confirmDeleteWear) { id in
            Button("Delete", role: .destructive) { Task { await model.deleteWear(id) } }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete this compliment?", isPresented: deleteComplimentBinding, presenting: confirmDeleteCompliment) { id in
            Button("Delete", role: .destructive) { Task { await model.deleteCompliment(id) } }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Loaded

    @ViewBuilder
    private var loaded: some View {
        if let item = model.item {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    hero(item)
                    statsRow
                    fillSlider
                    if !model.accords.isEmpty || model.hasPyramid { scentSection }
                    detailsSection(item)
                    wearHistorySection
                    complimentsSection
                    Color.clear.frame(height: 72)   // space for the pinned action bar
                }
                .padding(Theme.Spacing.lg)
            }
            .safeAreaInset(edge: .bottom) { actionBar }
        }
    }

    private func hero(_ item: CollectionItemRow) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            RemoteImage(bottlePhoto: item.photoUrl, fallbackURL: item.fragrance.imageUrl)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fragrance.name).font(Theme.Typography.display(24))
                    Text([item.fragrance.house, item.fragrance.concentration?.rawValue]
                        .compactMap { $0 }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
                Spacer()
                if item.status != .active {
                    Text(item.status.rawValue.capitalized)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Theme.Palette.secondaryBackground, in: Capsule())
                }
            }
            RatingView(rating: item.personalRating, size: 16)
        }
    }

    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.md) {
            stat("Worn", "\(model.wearCount)")
            stat("Compliments", "\(model.complimentCount)")
            stat("Cost / wear", model.costPerWear.map {
                $0.formatted(.currency(code: model.cost?.currency ?? "USD"))
            } ?? "—")
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(Theme.Palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.md))
    }

    private var fillSlider: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Fill level — \(Int(model.fillLevel))%")
                .font(.footnote).foregroundStyle(Theme.Palette.secondaryText)
            Slider(value: $model.fillLevel, in: 0...100, step: 1) { editing in
                if !editing { Task { await model.commitFillLevel() } }
            }
        }
    }

    private var scentSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionTitle("Scent")
            if !model.accords.isEmpty {
                FlowChips(model.accords)
            }
            if model.hasPyramid {
                ForEach(PyramidPosition.allCases, id: \.self) { position in
                    if let notes = model.notesByPosition[position], !notes.isEmpty {
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Text(position.rawValue.capitalized)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.Palette.secondaryText)
                                .frame(width: 56, alignment: .leading)
                            Text(notes.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }
                }
            } else {
                Text("Notes aren't catalogued for this one yet — accords only.")
                    .font(.caption).foregroundStyle(Theme.Palette.tertiaryText)
            }
        }
    }

    private func detailsSection(_ item: CollectionItemRow) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionTitle("Details")
            detailRow("Size", item.sizeMl.map { "\($0) ml" })
            detailRow("Purchased", item.purchaseDate)
            detailRow("From", item.purchaseLocation)
            detailRow("Batch", item.batchCode)
            if let price = model.cost?.price {
                detailRow("Paid", price.formatted(.currency(code: model.cost?.currency ?? "USD")))
            }
        }
    }

    private var wearHistorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionTitle("Wear history")
            if model.wears.isEmpty {
                Text("No wears logged yet.").font(.caption).foregroundStyle(Theme.Palette.tertiaryText)
            } else {
                ForEach(model.wears) { wear in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(wear.wornOn).font(.subheadline)
                            Text([DerivedValues.season(fromISODate: wear.wornOn)?.label,
                                  wear.occasion?.label]
                                .compactMap { $0 }.joined(separator: " · "))
                                .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                        }
                        Spacer()
                        if wear.isSotd {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(Theme.Palette.rating)
                                .accessibilityLabel("Scent of the day")
                        }
                        Button(role: .destructive) { confirmDeleteWear = wear.id } label: {
                            Image(systemName: "trash").font(.body).frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Delete wear from \(wear.wornOn)")
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                    Divider()
                }
            }
        }
    }

    private var complimentsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            sectionTitle("Compliments")
            if model.compliments.isEmpty {
                Text("None logged yet.").font(.caption).foregroundStyle(Theme.Palette.tertiaryText)
            } else {
                ForEach(model.compliments) { compliment in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(compliment.who ?? "Someone").font(.subheadline)
                            if let comment = compliment.comment {
                                Text(comment).font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                            }
                            Text(compliment.complimentedOn).font(.caption2).foregroundStyle(Theme.Palette.tertiaryText)
                        }
                        Spacer()
                        Button(role: .destructive) { confirmDeleteCompliment = compliment.id } label: {
                            Image(systemName: "trash").font(.body).frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Delete this compliment")
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                    Divider()
                }
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            Button { sheet = .logWear } label: {
                Label("Log wear", systemImage: "drop.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button { sheet = .logCompliment } label: {
                Label("Compliment", systemImage: "hands.clap.fill").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(Theme.Spacing.md)
        .background(.bar)
    }

    private var menu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button { sheet = .edit } label: { Label("Edit", systemImage: "pencil") }
                Menu("Status") {
                    ForEach(ItemStatus.allCases, id: \.self) { status in
                        Button {
                            if status == .active { Task { await model.setStatus(status) } }
                            else { confirmStatus = status }
                        } label: {
                            Label(status.rawValue.capitalized,
                                  systemImage: model.item?.status == status ? "checkmark" : "")
                        }
                    }
                }
                Divider()
                Button(role: .destructive) { confirmDeleteItem = true } label: {
                    Label("Delete bottle", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel("More actions")
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline)
    }

    @ViewBuilder
    private func detailRow(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack {
                Text(label).foregroundStyle(Theme.Palette.secondaryText)
                Spacer()
                Text(value)
            }
            .font(.subheadline)
        }
    }

    // Confirmation-dialog bindings from optional selections.
    private var statusConfirmBinding: Binding<Bool> {
        Binding(get: { confirmStatus != nil }, set: { if !$0 { confirmStatus = nil } })
    }
    private var deleteWearBinding: Binding<Bool> {
        Binding(get: { confirmDeleteWear != nil }, set: { if !$0 { confirmDeleteWear = nil } })
    }
    private var deleteComplimentBinding: Binding<Bool> {
        Binding(get: { confirmDeleteCompliment != nil }, set: { if !$0 { confirmDeleteCompliment = nil } })
    }
}

/// Simple wrapping chip row for accord families.
struct FlowChips: View {
    let items: [String]
    init(_ items: [String]) { self.items = items }

    var body: some View {
        FlexWrap(spacing: Theme.Spacing.xs) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Theme.Palette.secondaryBackground, in: Capsule())
            }
        }
    }
}

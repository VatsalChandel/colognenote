import SwiftUI

struct WishlistItemEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: WishlistItemEditViewModel

    init(editing row: WishlistRow? = nil) {
        _model = State(initialValue: WishlistItemEditViewModel(editing: row))
    }

    var body: some View {
        NavigationStack {
            Form {
                identitySection
                Section("Details") {
                    Picker("Stage", selection: $model.stage) {
                        ForEach(WishlistStage.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    LabeledContent("Target price") {
                        TextField("0.00", text: $model.targetPriceText)
                            .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                    }
                    TextField("Notes (samples tried, thoughts…)", text: $model.notes, axis: .vertical)
                        .lineLimit(1...4)
                }
                if let error = model.errorMessage {
                    Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
                }
            }
            .navigationTitle(model.isEditing ? "Edit wishlist item" : "Add to wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { if await model.save() { dismiss() } } }
                        .disabled(!model.canSave)
                }
            }
        }
    }

    @ViewBuilder
    private var identitySection: some View {
        if let fragrance = model.chosenFragrance {
            Section("Fragrance") {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fragrance.name).font(.headline)
                    Text([fragrance.house, fragrance.concentration?.rawValue]
                        .compactMap { $0 }.joined(separator: " · "))
                        .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                }
                Button("Change") { model.clearChoice() }.font(.footnote)
            }
        } else {
            Section("Search the catalog") {
                TextField("Fragrance name", text: $model.query)
                    .onChange(of: model.query) { model.search() }
                ForEach(model.results) { fragrance in
                    Button { model.choose(fragrance) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(fragrance.name).foregroundStyle(Theme.Palette.primaryText)
                            Text([fragrance.house, fragrance.concentration?.rawValue]
                                .compactMap { $0 }.joined(separator: " · "))
                                .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                        }
                    }
                }
            }
            Section("…or just type it") {
                TextField("Free text (e.g. that niche one I sampled)", text: $model.freeText)
            }
        }
    }
}

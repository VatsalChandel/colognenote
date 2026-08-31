import SwiftUI
import PhotosUI

/// Two-step Add flow, or a single-step Edit (screen spec #3, tasks 2.4–2.6).
struct AddFragranceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: AddFragranceViewModel
    @State private var photoItem: PhotosPickerItem?

    init(editing item: CollectionItemRow? = nil, cost: CollectionItemCost? = nil) {
        _model = State(initialValue: AddFragranceViewModel(editing: item, cost: cost))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch model.step {
                case .find:    findStep
                case .details: detailsStep
                }
            }
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if model.step == .details {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task { if await model.save() { dismiss() } }
                        }
                        .disabled(!model.canSave)
                    }
                }
            }
        }
    }

    // MARK: Step 1 — find it

    private var findStep: some View {
        List {
            if !model.showManualEntry {
                Section {
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
                } footer: {
                    if model.isSearching { Text("Searching…") }
                    else if model.query.trimmed.count >= 2 && model.results.isEmpty {
                        Text("No matches in the catalog.")
                    }
                }

                Section {
                    Button {
                        model.manualName = model.query.trimmed
                        model.showManualEntry = true
                    } label: {
                        Label("Add it manually", systemImage: "square.and.pencil")
                    }
                }
            } else {
                manualEntrySection
            }
        }
        .searchable(text: $model.query, prompt: "Search the catalog")
        .onChange(of: model.query) { model.search() }
    }

    private var manualEntrySection: some View {
        Group {
            Section("New fragrance") {
                TextField("Name", text: $model.manualName)
                TextField("House (optional)", text: $model.manualHouse)
                Picker("Concentration", selection: $model.manualConcentration) {
                    ForEach(Concentration.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
            }
            Section {
                Button("Continue") { Task { await model.createManualAndContinue() } }
                    .disabled(model.manualName.trimmed.isEmpty)
                Button("Back to search", role: .cancel) { model.showManualEntry = false }
            } footer: {
                if let error = model.errorMessage {
                    Text(error).foregroundStyle(Theme.Palette.destructive)
                }
            }
        }
    }

    // MARK: Step 2 — your details

    private var detailsStep: some View {
        Form {
            if let fragrance = model.selectedFragrance {
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(fragrance.name).font(.headline)
                        Text([fragrance.house, fragrance.concentration?.rawValue]
                            .compactMap { $0 }.joined(separator: " · "))
                            .font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                    }
                    if !model.isEditing {
                        Button("Choose a different fragrance") { model.step = .find }
                            .font(.footnote)
                    }
                }
            }

            Section("Yours") {
                LabeledContent("Price") {
                    TextField("0.00", text: $model.priceText)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Size (ml)") {
                    TextField("100", text: $model.sizeText)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                Toggle("Purchase date", isOn: $model.includePurchaseDate)
                if model.includePurchaseDate {
                    DatePicker("Date", selection: $model.purchaseDate, displayedComponents: .date)
                }
                TextField("Purchase location", text: $model.purchaseLocation)
                TextField("Batch code", text: $model.batchCode)
                HStack {
                    Text("Rating")
                    Spacer()
                    RatingView(rating: model.rating, size: 20) { model.rating = ($0 == model.rating) ? 0 : $0 }
                }
            }

            if !model.isEditing {
                Section("Photo") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(model.pickedImageData == nil ? "Add a photo" : "Photo added",
                              systemImage: "camera")
                    }
                }
            }

            if let error = model.errorMessage {
                Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
            }
        }
        .onChange(of: photoItem) { _, item in
            Task {
                guard
                    let data = try? await item?.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                else { return }
                model.pickedImageData = image.jpegData(maxDimension: 1024)
            }
        }
    }
}

#Preview {
    AddFragranceView()
}

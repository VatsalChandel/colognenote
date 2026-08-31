import SwiftUI

/// The fast compliment sheet — capture the moment before it's forgotten (screen spec #6).
struct LogComplimentView: View {
    let itemID: UUID
    var onLogged: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var model: LogComplimentViewModel

    init(itemID: UUID, onLogged: (() -> Void)? = nil) {
        self.itemID = itemID
        self.onLogged = onLogged
        _model = State(initialValue: LogComplimentViewModel(itemID: itemID))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $model.date, in: ...Date(), displayedComponents: .date)
                    TextField("Who said it (optional)", text: $model.who)
                    TextField("What they said (optional)", text: $model.comment, axis: .vertical)
                        .lineLimit(1...3)
                }

                if !model.recentWears.isEmpty {
                    Section("Attach to a wear") {
                        Picker("Wear", selection: $model.attachedWearID) {
                            Text("Not attached").tag(UUID?.none)
                            ForEach(model.recentWears) { wear in
                                Text(wear.wornOn
                                     + (wear.occasion.map { " · \($0.label)" } ?? ""))
                                    .tag(UUID?.some(wear.id))
                            }
                        }
                    }
                }

                if let error = model.errorMessage {
                    Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
                }
            }
            .navigationTitle("Log compliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { if await model.save() { onLogged?(); dismiss() } }
                    }
                    .disabled(model.isSaving)
                }
            }
            .task { await model.loadRecentWears() }
        }
        .presentationDetents([.medium, .large])
    }
}

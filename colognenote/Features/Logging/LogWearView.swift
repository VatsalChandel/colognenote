import SwiftUI

/// The fast wear sheet — two taps, then gone (screen spec #5).
struct LogWearView: View {
    let itemID: UUID
    var onLogged: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var model: LogWearViewModel

    init(itemID: UUID, onLogged: (() -> Void)? = nil) {
        self.itemID = itemID
        self.onLogged = onLogged
        _model = State(initialValue: LogWearViewModel(itemID: itemID))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: $model.date, in: ...Date(), displayedComponents: .date)

                    Picker("Occasion", selection: $model.occasion) {
                        Text("None").tag(Occasion?.none)
                        ForEach(Occasion.allCases, id: \.self) { Text($0.label).tag(Occasion?.some($0)) }
                    }

                    HStack {
                        Label(model.weatherSummary, systemImage: weatherIcon)
                            .font(.subheadline)
                            .foregroundStyle(Theme.Palette.secondaryText)
                        if model.weatherState == .loading { Spacer(); ProgressView() }
                    }

                    Toggle("Scent of the day", isOn: $model.isSotd)
                }

                Section("Pairing") {
                    TextField("What you wore it with (optional)", text: $model.pairing)
                }

                if let error = model.errorMessage {
                    Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
                }
            }
            .navigationTitle("Log wear")
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
            .task { await model.captureWeather() }
        }
        .presentationDetents([.medium, .large])
    }

    private var weatherIcon: String {
        switch model.weatherState {
        case .ready:       "cloud.sun"
        case .unavailable: "cloud.slash"
        default:           "cloud"
        }
    }
}

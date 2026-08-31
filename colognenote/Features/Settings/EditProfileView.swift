import SwiftUI
import PhotosUI

struct EditProfileView: View {
    let profile: Profile
    var onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var model: EditProfileViewModel
    @State private var photoItem: PhotosPickerItem?

    init(profile: Profile, onSaved: @escaping () -> Void) {
        self.profile = profile
        self.onSaved = onSaved
        _model = State(initialValue: EditProfileViewModel(profile: profile))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(model.pickedImageData == nil ? "Change photo" : "Photo selected",
                              systemImage: "camera")
                    }
                }
                Section("Display name") {
                    TextField("Display name", text: $model.displayName)
                }
                Section("Username") {
                    TextField("username", text: $model.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if model.usernameStatus == .checking {
                        Text("Checking…").font(.caption).foregroundStyle(Theme.Palette.secondaryText)
                    } else if model.usernameStatus == .available {
                        Text("Available").font(.caption).foregroundStyle(.green)
                    } else if let problem = model.usernameStatus.problem {
                        Text(problem).font(.caption).foregroundStyle(Theme.Palette.destructive)
                    }
                }
                Section("Bio") {
                    TextField("A line about you (optional)", text: $model.bio, axis: .vertical)
                        .lineLimit(1...4)
                }
                if let error = model.errorMessage {
                    Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
                }
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { if await model.save() { onSaved(); dismiss() } }
                    }
                    .disabled(!model.canSave)
                }
            }
            .task(id: model.username) { await model.checkUsername() }
            .onChange(of: photoItem) { _, item in
                Task {
                    guard
                        let data = try? await item?.loadTransferable(type: Data.self),
                        let image = UIImage(data: data)
                    else { return }
                    model.pickedImageData = image.jpegData(maxDimension: 512)
                }
            }
        }
    }
}

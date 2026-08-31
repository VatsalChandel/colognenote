import SwiftUI
import PhotosUI

/// First-run profile setup (task 1.4). Shown while `SessionStore.phase == .needsProfileSetup`.
struct ProfileSetupView: View {
    @Environment(SessionStore.self) private var session
    @State private var model = ProfileSetupViewModel()
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Set up your profile")
                        .font(Theme.Typography.display(28))
                    Text("This is how you'll show up if you go social later. Only your display name and username are ever public.")
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.xl)

                avatarPicker

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Display name").font(.footnote).foregroundStyle(Theme.Palette.secondaryText)
                    TextField("e.g. Vatsal", text: $model.displayName)
                        .textContentType(.name)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Username").font(.footnote).foregroundStyle(Theme.Palette.secondaryText)
                    HStack {
                        TextField("username", text: $model.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        usernameBadge
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))
                    if let hint = model.usernameStatus.hint {
                        Text(hint).font(.caption).foregroundStyle(Theme.Palette.destructive)
                    }
                }

                if let error = model.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button("Continue") {
                    Task {
                        if await model.save() { await session.refreshProfile() }
                    }
                }
                .buttonStyle(.primary(isLoading: model.isSaving))
                .disabled(!model.canSave)
            }
            .padding(Theme.Spacing.xl)
        }
        .background(Theme.Palette.background)
        .scrollDismissesKeyboard(.interactively)
        .task(id: model.username) { await model.checkAvailability() }
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

    private var avatarPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack {
                if let data = model.pickedImageData, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Circle().fill(Theme.Palette.secondaryBackground)
                    Image(systemName: "camera.fill").foregroundStyle(Theme.Palette.tertiaryText)
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(Circle())
            .overlay(Circle().stroke(Theme.Palette.separator))
        }
    }

    @ViewBuilder
    private var usernameBadge: some View {
        switch model.usernameStatus {
        case .checking:
            ProgressView()
        case .available:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .taken, .invalid:
            Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.Palette.destructive)
        case .empty:
            EmptyView()
        }
    }
}

#Preview {
    ProfileSetupView().environment(SessionStore())
}

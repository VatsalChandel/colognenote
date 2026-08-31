import SwiftUI

/// Small, but it holds the privacy promise + account (screen spec #9).
struct SettingsView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var model = SettingsViewModel()
    @State private var showEditProfile = false
    @State private var confirmDelete = false

    var body: some View {
        NavigationStack {
            Group {
                switch model.state {
                case .loading:
                    LoadingView()
                case .failed(let message):
                    ErrorView(message: message) { Task { await model.load() } }
                case .ready:
                    form
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .task { await model.load() }
        .sheet(isPresented: $showEditProfile) {
            if let profile = model.profile {
                EditProfileView(profile: profile) { Task { await model.load() } }
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        @Bindable var model = model

        Form {
            Section {
                Button("Edit profile") { showEditProfile = true }
                if let profile = model.profile {
                    LabeledContent("Username", value: profile.username)
                    if let name = profile.displayName, !name.isEmpty {
                        LabeledContent("Display name", value: name)
                    }
                }
            }

            Section {
                Toggle("Show collection value on my profile", isOn: Binding(
                    get: { model.profile?.showCollectionValue ?? false },
                    set: { on in Task { await model.setShowCollectionValue(on) } }
                ))
            } header: {
                Text("Privacy")
            } footer: {
                Text("What you paid and your collection's total value are always private — they never appear on a public profile or in any feed. This toggle only offers your collection's value as an optional flex, and it's off by default.")
            }

            Section {
                NotificationPrefsPlaceholder()
            } header: {
                Text("Notifications")
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await session.signOut()
                        dismiss()
                    }
                } label: {
                    Text("Log out")
                }
                Button(role: .destructive) { confirmDelete = true } label: {
                    Text("Delete account")
                }
            }

            if let error = model.errorMessage {
                Section { Text(error).foregroundStyle(Theme.Palette.destructive) }
            }
        }
        .confirmationDialog(
            "Delete your account?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive) {
                Task {
                    await model.deleteAccount { await session.signOut() }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your profile, every bottle, and all your wear and compliment history. It can't be undone.")
        }
        .disabled(model.isBusy)
    }
}

private struct NotificationPrefsPlaceholder: View {
    var body: some View {
        Text("SOTD reminders and new-follower alerts arrive with the social layer (Phase 2).")
            .font(.footnote)
            .foregroundStyle(Theme.Palette.secondaryText)
    }
}

#Preview {
    SettingsView().environment(SessionStore())
}

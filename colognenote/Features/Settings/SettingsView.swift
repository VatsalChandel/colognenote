import SwiftUI

/// Minimal for Milestone 1 — just log out, so session handling (1.3) is testable.
/// Privacy toggle, edit profile, delete account arrive in Milestone 5.
struct SettingsView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(role: .destructive) {
                        Task {
                            isSigningOut = true
                            await session.signOut()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text("Log out")
                            if isSigningOut { Spacer(); ProgressView() }
                        }
                    }
                    .disabled(isSigningOut)
                }

                Section {
                    Text("Privacy, profile editing and account deletion arrive in Milestone 5.")
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView().environment(SessionStore())
}

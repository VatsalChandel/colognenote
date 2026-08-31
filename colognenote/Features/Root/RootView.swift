import SwiftUI

/// Top-level router. Switches the whole UI on auth + onboarding phase (task 1.6).
struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        switch session.phase {
        case .loading:
            LoadingView(label: "Starting up…")
        case .signedOut:
            AuthView()
        case .needsProfileSetup:
            ProfileSetupView()
        case .ready:
            MainTabView()
        }
    }
}

#Preview {
    RootView().environment(SessionStore())
}

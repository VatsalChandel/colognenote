import SwiftUI

/// Top-level router. Switches the whole UI on auth state.
struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        switch session.state {
        case .loading:
            LoadingView(label: "Starting up…")
        case .signedOut:
            AuthView()
        case .signedIn:
            MainTabView()
        }
    }
}

#Preview {
    RootView().environment(SessionStore())
}

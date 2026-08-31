import SwiftUI

/// Sign in / sign up. One form, mode toggle. Username and avatar come later, in
/// profile setup — keeping this screen to the two fields auth actually needs.
struct AuthView: View {
    @State private var model = AuthViewModel()
    @State private var showForgotPassword = false
    @FocusState private var focused: Field?

    private enum Field { case email, password, displayName }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                header

                VStack(spacing: Theme.Spacing.md) {
                    if model.mode == .signUp {
                        field("Display name", text: $model.displayName, field: .displayName)
                            .textContentType(.name)
                            .submitLabel(.next)
                    }

                    field("Email", text: $model.email, field: .email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)

                    SecureField("Password", text: $model.password)
                        .textContentType(model.mode == .signIn ? .password : .newPassword)
                        .focused($focused, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await model.submit() } }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))

                    if model.mode == .signIn {
                        Button("Forgot password?") { showForgotPassword = true }
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                if let error = model.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(model.submitLabel) { Task { await model.submit() } }
                    .buttonStyle(.primary(isLoading: model.isSubmitting))
                    .disabled(!model.canSubmit)

                Button(model.switchPrompt) { model.toggleMode() }
                    .font(.subheadline)
            }
            .padding(Theme.Spacing.xl)
        }
        .background(Theme.Palette.background)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(initialEmail: model.email)
        }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "drop.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.Palette.accent)
                .accessibilityHidden(true)
            Text("Cologne")
                .font(Theme.Typography.display(34))
            Text(model.title)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .padding(.top, Theme.Spacing.xxl)
    }

    private func field(_ label: String, text: Binding<String>, field: Field) -> some View {
        TextField(label, text: text)
            .focused($focused, equals: field)
            .padding(Theme.Spacing.md)
            .background(Theme.Palette.secondaryBackground, in: RoundedRectangle(cornerRadius: Theme.Radius.sm))
    }
}

#Preview {
    AuthView()
}

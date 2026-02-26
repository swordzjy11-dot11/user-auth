import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegisterView = false
    @State private var showingForgotPasswordView = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign in to your account")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    Spacer()

                    Button("Forgot Password?") {
                        showingForgotPasswordView = true
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
            .padding(.top, 20)

            Button(action: login) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(authManager.isLoading)

            Divider()

            // Social Login Options
            VStack(spacing: 12) {
                Text("Or sign in with")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    Button(action: {
                        authManager.initiateGoogleOAuth()
                    }) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.34, green: 0.47, blue: 0.99))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Sign in with Google")

                    Button(action: {
                        authManager.initiateWeChatOAuth()
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                            .foregroundColor(Color.green)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Sign in with WeChat")
                }
            }

            HStack {
                Text("Don't have an account?")

                Button("Sign Up") {
                    showingRegisterView = true
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
            .font(.caption)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $showingRegisterView) {
            RegisterView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingForgotPasswordView) {
            ForgotPasswordView()
                .environmentObject(authManager)
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { authManager.errorMessage != nil },
            set: { if !$0 { authManager.errorMessage = nil } }
        )) {
            Button("OK") {
                authManager.errorMessage = nil
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
    }

    private func login() {
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                authManager.errorMessage = error.localizedDescription
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager(isPreview: true))
    }
}
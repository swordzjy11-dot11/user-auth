import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var isSent = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            if !isSent {
                Text("Reset Your Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter your email and we'll send you a link to reset your password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                }
                .padding(.top, 20)

                Button(action: resetPassword) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(authManager.isLoading || !isValidEmail)
            } else {
                // Success state
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)

                Text("Reset Link Sent!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We've sent a password reset link to \(email). Please check your inbox.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Back to Login") {
                    // Dismiss this view
                }
                .padding(.top)
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 400)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }

    private func resetPassword() {
        Task {
            do {
                try await authManager.sendVerificationCode(to: email)
                DispatchQueue.main.async {
                    isSent = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environmentObject(AuthManager(isPreview: true))
    }
}
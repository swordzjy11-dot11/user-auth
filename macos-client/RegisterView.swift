import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingVerificationView = false
    @State private var verificationCode = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Fill in the information below")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.top, 20)

                Button(action: register) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(authManager.isLoading || !isFormValid)

                NavigationLink(destination: VerificationView(
                    email: email,
                    name: name,
                    password: password
                ).environmentObject(authManager), isActive: $showingVerificationView) {
                    EmptyView()
                }
            }
            .padding(40)
            .frame(minWidth: 400, minHeight: 500)
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && email.contains("@")
    }

    private func register() {
        Task {
            do {
                try await authManager.register(name: name, email: email, password: password)
                // After registration, we might need to handle verification
                // For now, showing a verification view
                showingVerificationView = true
            } catch {
                authManager.errorMessage = error.localizedDescription
            }
        }
    }
}

// Verification view for email verification code
struct VerificationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var verificationCode = ""
    @State private var secondsRemaining = 60
    @State private var isResendDisabled = true

    let email: String
    let name: String
    let password: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter the verification code sent to \(email)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextField("Verification Code", text: $verificationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                .multilineTextAlignment(.center)

            Button(action: verifyCode) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Verify Code")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(authManager.isLoading || verificationCode.count != 6)

            if isResendDisabled {
                Text("Resend code in \(secondsRemaining)s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Button("Resend Verification Code") {
                    resendCode()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }

            Button("Back to Sign Up") {
                // Go back to registration
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 400)
        .onAppear {
            sendVerificationCode()
            startTimer()
        }
    }

    private func sendVerificationCode() {
        Task {
            do {
                try await authManager.sendVerificationCode(to: email)
            } catch {
                authManager.errorMessage = error.localizedDescription
            }
        }
    }

    private func verifyCode() {
        // For now, we'll use the forgot password API since we don't have a dedicated verification endpoint
        // In a real app, we'd have a dedicated verification endpoint
        Task {
            do {
                // Since the backend doesn't have a specific verification endpoint,
                // we'll just complete registration using the password
                // The verification is typically done via email, but for demo purposes:

                // Just authenticate the user (in a real scenario, the backend would validate the code)
                try await authManager.login(email: email, password: password)
            } catch {
                authManager.errorMessage = error.localizedDescription
            }
        }
    }

    private func resendCode() {
        sendVerificationCode()
        secondsRemaining = 60
        isResendDisabled = true
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                isResendDisabled = false
                timer.invalidate()
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthManager(isPreview: true))
    }
}
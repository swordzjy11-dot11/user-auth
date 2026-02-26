import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingProfileEditor = false
    @State private var showingChangePassword = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let user = authManager.currentUser {
                        VStack(alignment: .leading) {
                            HStack {
                                if let avatar = user.avatar {
                                    AsyncImage(url: URL(string: avatar)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }

                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)

                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Text("Role: \(user.role)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }

                            if let socialAccounts = user.socialAccounts, !socialAccounts.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Connected Accounts:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    HStack(spacing: 8) {
                                        ForEach(socialAccounts) { account in
                                            HStack(spacing: 4) {
                                                // Show icon based on provider
                                                Image(systemName: account.provider == "google" ? "g.circle.fill" : "person.crop.circle.fill")
                                                    .foregroundColor(account.provider == "google" ? Color(red: 0.34, green: 0.47, blue: 0.99) : Color.green)

                                                Text(capitalizeFirst(account.provider))
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }

                        Spacer()

                        Button("Sign Out") {
                            authManager.logout()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Account Settings")
                        .font(.title3)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        Button(action: { showingProfileEditor = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)

                                Text("Edit Profile")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }

                        Button(action: { showingChangePassword = true }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(.orange)

                                Text("Change Password")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }

                        Button(action: {
                            // Add social accounts feature
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .foregroundColor(.green)

                                Text("Connect Social Account")

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .frame(minWidth: 600, minHeight: 400)
            .sheet(isPresented: $showingProfileEditor) {
                ProfileEditorView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
                    .environmentObject(authManager)
            }
        }
    }

    private func capitalizeFirst(_ text: String) -> String {
        guard let first = text.first else { return text }
        return String(first).uppercased() + text.dropFirst()
    }
}

struct ProfileEditorView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var email = ""
    @State private var avatarURL = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.title2)
                .fontWeight(.bold)

            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .disabled(true) // Email shouldn't be editable in this view for security
                    TextField("Avatar URL", text: $avatarURL)
                }
            }

            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }

                Spacer()

                Button("Save") {
                    // Implement save functionality
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isValidInput)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            if let user = authManager.currentUser {
                name = user.name
                email = user.email
                avatarURL = user.avatar ?? ""
            }
        }
    }

    private var isValidInput: Bool {
        !name.isEmpty && email.contains("@")
    }
}

struct ChangePasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Change Password")
                .font(.title2)
                .fontWeight(.bold)

            Form {
                Section(header: Text("Password Information")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }
            }

            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }

                Spacer()

                Button("Update Password") {
                    changePassword()
                }
                .disabled(!isValidInput)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var isValidInput: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && newPassword.count >= 6 && newPassword == confirmPassword
    }

    private func changePassword() {
        // Placeholder for change password functionality
        // This would involve calling an API endpoint
        errorMessage = "Password change functionality would be implemented here"
        showError = true
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthManager(isPreview: true))
    }
}
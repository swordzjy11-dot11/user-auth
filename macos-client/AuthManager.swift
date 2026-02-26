import Foundation
import Combine
import AppKit

// MARK: - Models
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatar: String?
    let role: String
    let socialAccounts: [SocialAccount]?

    enum CodingKeys: String, CodingKey {
        case id, name, email, avatar, role
        case socialAccounts = "socialAccounts"
    }
}

struct SocialAccount: Codable, Identifiable {
    let id: Int
    let userId: Int
    let provider: String
    let providerId: String
    let email: String?
    let name: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case provider, providerId, email, name
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let token: String?
    let user: User?
    let resetToken: String?
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let password: String
}

// MARK: - AuthManager
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "http://localhost:5000/api/auth"
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "AuthToken"

    // Private init for shared instance
    private init() {
        loadToken()
    }

    // Internal init for previews only
    init(isPreview: Bool = false) {
        loadToken()
        // In preview mode, we can set up mock data if needed
        if isPreview {
            isAuthenticated = true
            currentUser = User(id: 1, name: "Preview User", email: "preview@example.com", avatar: nil, role: "user", socialAccounts: [])
        }
    }

    // Load saved token on startup
    private func loadToken() {
        if let token = userDefaults.string(forKey: tokenKey) {
            authToken = token
            isAuthenticated = true
        }
    }

    // Save token to persistent storage
    private func saveToken(_ token: String) {
        authToken = token
        userDefaults.set(token, forKey: tokenKey)
        isAuthenticated = true
    }

    // Clear stored token
    private func clearToken() {
        authToken = nil
        currentUser = nil
        userDefaults.removeObject(forKey: tokenKey)
        isAuthenticated = false
    }

    // Check authentication status using saved token
    func checkAuthenticationStatus() {
        guard let token = authToken else { return }

        Task {
            do {
                let user = try await getCurrentUser(token: token)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.clearToken()
                }
            }
        }
    }

    // MARK: - API Methods

    // Register a new user
    func register(name: String, email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let request = RegisterRequest(name: name, email: email, password: password)
        let url = URL(string: "\(baseURL)/register")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 201 {
            let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            throw AuthError.serverError(errorResponse.message ?? "Unknown error")
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

        if let token = authResponse.token {
            saveToken(token)
            currentUser = authResponse.user
        }
    }

    // Login user
    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let request = LoginRequest(email: email, password: password)
        let url = URL(string: "\(baseURL)/login")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            throw AuthError.serverError(errorResponse.message ?? "Unknown error")
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

        if let token = authResponse.token {
            saveToken(token)
            currentUser = authResponse.user
        }
    }

    // Get current user info
    private func getCurrentUser(token: String) async throws -> User {
        let url = URL(string: "\(baseURL)/me")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            throw AuthError.serverError(errorResponse.message ?? "Unknown error")
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

        guard let user = authResponse.user else {
            throw AuthError.invalidResponse
        }

        return user
    }

    // Send verification code
    func sendVerificationCode(to email: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let request = ForgotPasswordRequest(email: email)
        let url = URL(string: "\(baseURL)/forgot-password")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            throw AuthError.serverError(errorResponse.message ?? "Unknown error")
        }

        // The backend sends a reset token which we could treat as verification
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        print("Verification/reset token: \(authResponse.resetToken ?? "none")")
    }

    // Verify code and complete registration
    func verifyCodeAndCompleteRegistration(email: String, code: String, password: String) async throws {
        // Note: The backend doesn't have a specific verification endpoint
        // So we'll use the reset password endpoint
        let url = URL(string: "\(baseURL)/reset-password/\(code)")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let request = ResetPasswordRequest(password: password)
        let jsonData = try JSONEncoder().encode(request)
        urlRequest.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            throw AuthError.serverError(errorResponse.message ?? "Unknown error")
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

        if let token = authResponse.token {
            saveToken(token)
            currentUser = authResponse.user
        }
    }

    // Logout
    func logout() {
        clearToken()
    }

    // Handle Google OAuth
    func initiateGoogleOAuth() {
        // Open the OAuth URL in the default browser
        if let url = URL(string: "\(baseURL)/google") {
            NSWorkspace.shared.open(url)
        }
    }

    // Handle WeChat OAuth
    func initiateWeChatOAuth() {
        // Open the OAuth URL in the default browser
        if let url = URL(string: "\(baseURL)/wechat") {
            NSWorkspace.shared.open(url)
        }
    }
}

enum AuthError: LocalizedError {
    case invalidResponse
    case serverError(String)
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message
        case .invalidCredentials:
            return "Invalid email or password"
        }
    }
}
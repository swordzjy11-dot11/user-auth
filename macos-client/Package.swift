// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AuthClient",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "AuthClient",
            targets: ["AuthClient"]
        )
    ],
    dependencies: [
        // No external dependencies for basic authentication client
    ],
    targets: [
        .executableTarget(
            name: "AuthClient",
            dependencies: [],
            path: ".",
            sources: [
                "AuthApp.swift",
                "ContentView.swift",
                "AuthManager.swift",
                "LoginView.swift",
                "RegisterView.swift",
                "ForgotPasswordView.swift",
                "DashboardView.swift"
            ],
            resources: []
        )
    ]
)
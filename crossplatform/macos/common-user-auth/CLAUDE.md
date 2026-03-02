# macOS Client App - Project Documentation

This document provides guidance for working with the CommonUserAuth macOS client application.

## Project Overview

CommonUserAuth is a native macOS application that connects to the user-auth backend API, providing a complete authentication experience with email registration, verification, and social login support.

## Architecture

### Technology Stack
- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM pattern with Combine for reactive programming
- **API Integration**: URLSession with async/await
- **State Management**: ObservableObject with Published properties
- **Threading**: Uses MainActor for UI updates to avoid "Publishing changes from background threads" error

### Key Components

#### AuthManager.swift
The central authentication manager that handles all API communication:
- User registration, login, and profile management
- Password recovery flows
- Social authentication (Google, WeChat)
- Token storage and session management
- Network request handling with proper error handling
- **New Alert System**: Shows user-friendly popups for success/error messages during registration, login, verification, and other operations

#### Views
- **ContentView.swift**: Main application view
- **LoginView.swift**: Email/password login with social login options
- **RegisterView.swift**: New user registration form
- **DashboardView.swift**: User profile and account management
- **ForgotPasswordView.swift**: Password recovery flow

## Key Features

### Authentication Flows
- **Email Registration**: Create new accounts with name, email, and password
- **Email Login**: Secure login with email and password
- **Password Recovery**: Reset forgotten passwords via email verification
- **Social Login**: Sign in with Google and WeChat accounts
- **Account Linking**: Link social accounts to existing email accounts

### User Profile Management
- View and edit user profile information
- Change account password
- View connected social accounts
- Secure session management

## API Endpoints Used

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User authentication
- `GET /api/auth/me` - Get current user info
- `PUT /api/auth/me` - Update user profile
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password/:token` - Complete password reset
- `PUT /api/auth/change-password` - Change current password
- `GET /api/auth/google` - Initiate Google OAuth
- `GET /api/auth/wechat` - Initiate WeChat OAuth

## Configuration

The application expects the backend API to be running at `http://localhost:3000/api/auth`. To use a different endpoint:

1. Update the `baseURL` property in `AuthManager.swift`
2. Ensure CORS settings in the backend allow the application domain

## Security Considerations

- JWT tokens are stored in UserDefaults with limited protection
- For production, consider using the Keychain for token storage
- All API communications should use HTTPS in production
- OAuth flows are handled through the default browser for security
- The app uses macOS sandboxing with proper entitlements:
  - `com.apple.security.network.client` for network access
  - `com.apple.security.files.user-selected.read-only` for file access
  - `com.apple.security.files.downloads.read-write` for downloads folder access
  - `com.apple.security.files.application-support.read-write` for app support folder access
  - `com.apple.security.application-groups` for shared app group container (useful for state restoration and shared data)

## Known Issues and Solutions

### Threading Issues
- **Problem**: "Publishing changes from background threads is not allowed"
- **Solution**: All UI updates are wrapped in `await MainActor.run` blocks

### OAuth Popup Communication
- **Problem**: OAuth flows in popups need to communicate back to parent app
- **Solution**: Backend returns HTML that sends tokens via `postMessage` to opener window

### macOS Sandboxing
- **Problem**: App cannot access network due to sandbox restrictions
- **Solution**: Added `com.apple.security.network.client` entitlement

### File Persistence
- **Problem**: "fopen failed for data file: errno = 2 (No such file or directory)" when saving avatar URLs or other files
- **Solution**: Added proper file access entitlements (`com.apple.security.files.downloads.read-write`, `com.apple.security.files.application-support.read-write`) to allow the app to save files to appropriate directories
- **Additional Note**: The app must save files to sandboxed locations like the Downloads folder or Application Support folder, not arbitrary locations

### State Restoration and Remote View Controller
- **Problem**: "TUINSRemoteViewController does not override -viewServiceDidTerminateWithError:" and "_NSPersistentUIDeleteItemAtFileURL" errors related to app state restoration
- **Solution**: Added application groups entitlement (`com.apple.security.application-groups`) which provides a shared container that helps with state restoration issues in sandboxed applications
- **Alternative Solution**: Disable state restoration if not needed by setting `NSQuitAlwaysKeepsWindows` to `false` in Info.plist
- **Text Input Services Issue**: This specific TUINSRemoteViewController error is often related to input methods and text services. This is commonly a system-level issue that appears in sandboxed apps but doesn't necessarily break functionality. To minimize this error:
  - Add `com.apple.security.temporary-exception.mach-lookup.global-name` exceptions if needed (though this reduces security)
  - Or, accept that this is a common macOS sandboxing message that may not impact app functionality
  - Check if it's related to third-party input methods installed on the user's system

### User Feedback System
- **Feature**: Added user-friendly alert system to provide feedback for all operations (login, register, logout, OAuth initiation, etc.)
- **Implementation**: Added new published properties (`showAlert`, `alertTitle`, `alertMessage`) to AuthManager and enhanced all methods to show appropriate success/error messages
- **Benefits**: Users now receive clear feedback about the outcome of their actions, improving the overall user experience

## Building the Application

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Setup
1. Ensure the backend API is running at the configured URL
2. Open the project in Xcode
3. Verify the entitlements file has the correct permissions
4. Build and run the application

### Running with Xcode
1. Open Xcode
2. Choose "Open a project or file"
3. Select the CommonUserAuth.xcodeproj
4. Build and run the application (Cmd+R)

## Troubleshooting

### Connection Errors
- Verify the backend API is running at the configured URL (default: http://localhost:3000)
- Check that the network client entitlement is properly set in the entitlements file
- Ensure the firewall is not blocking the connection

### Authentication Failures
- Verify that JWT secrets match between client and server
- Check that the server's JWT_SECRET environment variable is set
- Confirm the token hasn't expired

### OAuth Issues
- Ensure OAuth redirect URLs are configured correctly in the backend
- Verify the CLIENT_URL environment variable in the backend
- Check proxy settings if the server is behind a corporate firewall

### Build Issues
- Verify all required frameworks are linked
- Check that the provisioning profile is valid
- Ensure code signing is properly configured
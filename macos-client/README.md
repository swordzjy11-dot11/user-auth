# User Authentication macOS Client

A native macOS application that connects to the user-auth backend API, providing a complete authentication experience with email registration, verification, and social login support.

## Features

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

## Technical Details

### Architecture
- **Language**: Swift
- **Framework**: SwiftUI
- **API Integration**: URLSession with async/await
- **Data Storage**: UserDefaults for JWT token persistence
- **Security**: Bearer token authentication

### API Endpoints Used
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User authentication
- `GET /api/auth/me` - Get current user info
- `PUT /api/auth/me` - Update user profile
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password/:token` - Complete password reset
- `PUT /api/auth/change-password` - Change current password
- `GET /api/auth/google` - Initiate Google OAuth
- `GET /api/auth/wechat` - Initiate WeChat OAuth

## Building the Application

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Setup
1. Clone the repository
2. Navigate to the `macos-client` directory
3. Open the project in Xcode or use Swift Package Manager

### Running with Xcode
1. Open Xcode
2. Choose "Open a project or file"
3. Select the `macos-client` folder
4. Build and run the application (Cmd+R)

### Running with Swift Package Manager
```bash
cd macos-client
swift run AuthClient
```

## Configuration

The application expects the backend API to be running at `http://localhost:5000`. To use a different endpoint:

1. Update the `baseURL` property in `AuthManager.swift`
2. Ensure CORS settings in the backend allow the application domain

## Security Considerations

- JWT tokens are stored in UserDefaults with limited protection
- For production, consider using the Keychain for token storage
- All API communications should use HTTPS in production
- OAuth flows are handled through the default browser for security

## API Integration

The client handles all authentication flows defined in the backend API:

- **Registration Flow**: Collects user details, sends to backend, handles verification
- **Login Flow**: Authenticates user credentials, stores JWT token
- **Social Login Flow**: Opens OAuth URLs in browser, manages return flow
- **Password Recovery**: Sends reset requests, handles token validation

## Screenshots

The application includes:

1. **Login Screen**: Email/password login with social login options
2. **Registration Screen**: New user signup form
3. **Verification Screen**: Email verification code entry
4. **Dashboard**: User profile and account management
5. **Profile Editor**: Update personal information
6. **Password Change**: Secure password updates

## Dependencies

The application uses only built-in Swift and SwiftUI libraries:

- Foundation
- Combine
- SwiftUI
- UniformTypeIdentifiers

No external dependencies are required for core functionality.

## Backend Requirements

Ensure the following endpoints are available:

- User registration and authentication (`/api/auth/register`, `/api/auth/login`)
- User profile management (`/api/auth/me`)
- Password recovery (`/api/auth/forgot-password`, `/api/auth/reset-password/:token`)
- Social login (`/api/auth/google`, `/api/auth/wechat`)

## Troubleshooting

### Common Issues
- **Connection Errors**: Verify the backend API is running at the configured URL
- **Authentication Failures**: Check that JWT secrets match between client and server
- **OAuth Issues**: Ensure OAuth redirect URLs are configured correctly

### Debugging
Enable additional logging by adding debug prints in the `AuthManager` methods.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
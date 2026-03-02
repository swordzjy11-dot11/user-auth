# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## User Authentication API - Project Overview

This is a comprehensive user authentication system with JWT-based authentication and social login capabilities. The project includes both a Node.js/Express API backend and a native macOS client application.

## Project Structure

```
user-auth/
├── app.js                           # Main application entry point
├── db.js                           # Database connection and configuration
├── package.json                    # Project dependencies and scripts
├── database_schema.sql             # PostgreSQL schema for users and social accounts
├── config/
│   └── passport.js                 # Passport.js authentication strategies
├── middleware/
│   ├── auth.js                     # JWT authentication middleware
│   └── validation.js               # Input validation middleware
├── models/
│   └── User.js                     # User model with database operations
├── routes/
│   ├── auth.js                     # Core authentication routes
│   └── social.js                   # Social authentication routes
├── utils/
│   └── jwt.js                      # JWT token utilities
├── macos-client/                   # Native macOS client application
│   ├── AuthManager.swift           # Authentication manager with API integration
│   ├── ContentView.swift           # Main application view
│   ├── LoginView.swift             # Login screen
│   ├── RegisterView.swift          # Registration screen
│   ├── DashboardView.swift         # User dashboard
│   ├── ForgotPasswordView.swift    # Password recovery
│   ├── AuthApp.swift               # Application entry point
│   └── README.md                   # macOS client documentation
└── ...
```

## Architecture

### Backend (Node.js/Express)
- **Database**: PostgreSQL with tables for users and social accounts
- **Authentication**: JWT-based with Passport.js strategies (Local, JWT, Google OAuth2)
- **Security**: bcrypt password hashing, helmet security headers, express-rate-limit
- **Validation**: express-validator for input validation
- **Environment**: dotenv for configuration management

### Frontend (Native macOS)
- **Language**: Swift
- **Framework**: SwiftUI
- **Architecture**: MVVM pattern with Combine for reactive programming
- **API Integration**: URLSession with async/await
- **State Management**: ObservableObject with Published properties

## Key Endpoints

### Authentication Routes
- `GET /api/auth/` - Health check endpoint
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user profile
- `PUT /api/auth/me` - Update user profile
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password/:resetToken` - Reset password
- `PUT /api/auth/change-password` - Change password

### Social Authentication Routes
- `GET /api/auth/google` - Initiate Google OAuth
- `GET /api/auth/google/callback` - Google OAuth callback
- `GET /api/auth/wechat` - Initiate WeChat OAuth (Note: May be deprecated)

## Database Schema

The application uses PostgreSQL with three main tables:
- **users**: Stores user profiles with email, password (hashed), avatar, role, etc.
- **social_accounts**: Links social provider accounts to users
- **sessions**: Stores session data (optional)

## Common Development Tasks

### Running the Application
```bash
# Install dependencies
npm install

# Start in development mode
npm run dev

# Start in production mode
npm start

# Run tests
npm test
```

### Setting up OAuth
1. For Google OAuth: Create a project in Google Cloud Console
2. Enable Google People API
3. Create OAuth 2.0 credentials with redirect URIs:
   - `http://localhost:3000/api/auth/google/callback`
   - `http://localhost:3000/api/auth/google/callback?callback=popup`
4. Update your `.env` file with the OAuth credentials

### Environment Variables
Required variables in `.env`:
```
POSTGRES_URI=postgresql://username:password@localhost:5432/user_auth_db
JWT_SECRET=your-super-secret-jwt-key-here-make-it-long-and-random
JWT_EXPIRE=7d
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
PORT=5000
NODE_ENV=development
CLIENT_URL=http://localhost:3000
HTTPS_PROXY=your-proxy-url-if-needed
```

## Special Considerations

### OAuth Configuration
The OAuth flow supports both popup windows and traditional redirects. The Google OAuth callback endpoint returns HTML that sends authentication data via `postMessage` to the opener window when accessed from a popup.

### Proxy Configuration
The application includes proxy support for OAuth requests, particularly important for Google OAuth when behind corporate firewalls. This is configured in `app.js` using `https-proxy-agent`.

### Security Features
- Passwords are hashed using bcrypt
- JWT tokens for session management
- Input validation with express-validator
- Rate limiting to prevent abuse
- Security headers with helmet
- CORS enabled for cross-origin requests

### Error Handling
The application implements comprehensive error handling with detailed error responses in development mode and generic responses in production.

## macOS Client Specifics

The macOS client includes a complete authentication flow with:
- Email/password registration and login
- Social login via Google and WeChat
- Password recovery flow
- Profile management
- Session persistence using UserDefaults

## Troubleshooting

### OAuth Issues
- Check Google Cloud Console OAuth configuration
- Ensure redirect URIs match exactly
- Verify environment variables are set correctly
- Check proxy settings if behind firewall

### Database Issues
- Ensure PostgreSQL is running
- Verify database connection string
- Run the schema creation script if needed

### macOS Client Build Issues
- Ensure the backend API is running at the configured URL
- Check that the app has proper network entitlements
- Verify all required frameworks are linked
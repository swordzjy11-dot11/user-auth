# User Authentication API

A comprehensive user authentication system with JWT-based authentication and social login capabilities (Google, WeChat).

## Features

- JWT-based authentication
- Traditional email/password registration and login
- Social authentication (Google, WeChat)
- Password reset functionality
- Account linking/unlinking for social accounts
- Input validation and sanitization
- Rate limiting
- Security headers

## Prerequisites

- Node.js (v14 or higher)
- PostgreSQL
- Google and/or WeChat OAuth credentials (for social login)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd user-auth
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file based on the `.env.example` and fill in your credentials:
```env
# Database
POSTGRES_URI=postgresql://username:password@localhost:5432/user_auth_db

# JWT
JWT_SECRET=your-super-secret-jwt-key-here-make-it-long-and-random
JWT_EXPIRE=7d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# WeChat OAuth
WECHAT_APP_ID=your-wechat-app-id
WECHAT_APP_SECRET=your-wechat-app-secret

# Server
PORT=5000
NODE_ENV=development
```

## Running the Application

To run in development mode:
```bash
npm run dev
```

To run in production mode:
```bash
npm start
```

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register a new user |
| POST | `/api/auth/login` | Login with email and password |
| GET | `/api/auth/me` | Get current user profile |
| PUT | `/api/auth/me` | Update user profile |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password/:resetToken` | Reset password |
| PUT | `/api/auth/change-password` | Change password |

### Social Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/auth/google` | Initiate Google OAuth |
| GET | `/api/auth/google/callback` | Google OAuth callback |
| GET | `/api/auth/wechat` | Initiate WeChat OAuth |
| GET | `/api/auth/wechat/callback` | WeChat OAuth callback |

## Environment Variables

- `POSTGRES_URI`: Your PostgreSQL connection string
- `JWT_SECRET`: Secret key for JWT signing (should be a long, random string)
- `JWT_EXPIRE`: JWT expiration time (e.g., '7d' for 7 days)
- `GOOGLE_CLIENT_ID` & `GOOGLE_CLIENT_SECRET`: Google OAuth credentials
- `WECHAT_APP_ID` & `WECHAT_APP_SECRET`: WeChat OAuth credentials
- `PORT`: Port number for the server (default: 5000)
- `NODE_ENV`: Environment (development/production)

## Database Schema

The application uses PostgreSQL with an ORM/ODM. The User model includes:

- Basic user information (name, email, password)
- Avatar URL
- Role (user/admin)
- Password reset tokens
- Social account links
- Account status and last login timestamp

## Security Features

- Password hashing with bcrypt
- JWT-based authentication
- Input validation with express-validator
- Rate limiting to prevent abuse
- Helmet for security headers
- CORS enabled
- Password strength requirements

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
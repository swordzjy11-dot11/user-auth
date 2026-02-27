# Google OAuth Setup Guide

## Issue: "Failed to obtain access token" Error

If you're encountering the error `InternalOAuthError: Failed to obtain access token`, it's typically due to misconfiguration in your Google Cloud Console OAuth settings.

## Required Configuration

### 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Enable the Google+ API (or Google People API)
4. Go to "Credentials" in the left menu
5. Click "Create Credentials" > "OAuth 2.0 Client IDs"
6. Set up the application type as "Web Application"

### 2. Authorized Redirect URIs

Add the following URIs to your OAuth 2.0 client configuration:

- `http://localhost:3000/api/auth/google/callback`
- `http://localhost:3000/api/auth/google/callback?callback=popup`

### 3. Environment Variables

Ensure your `.env` file has the correct values:

```env
GOOGLE_CLIENT_ID=your_actual_google_client_id
GOOGLE_CLIENT_SECRET=your_actual_google_client_secret
CLIENT_URL=http://localhost:3000
```

### 4. Common Issues

- **URI Mismatch**: Make sure the `callbackURL` in your passport configuration matches exactly what's registered in Google Cloud Console
- **Missing API**: Ensure Google People API is enabled (was previously Google+ API)
- **Wrong Application Type**: Must be configured as "Web Application" not "Desktop Application"
- **Domain Verification**: If using in production, ensure your domain is verified

### 5. Testing

After setting up:

1. Restart your server
2. Try the Google OAuth flow again
3. Check server logs for any remaining errors

## WeChat OAuth (Coming Soon)

WeChat OAuth requires additional setup in the WeChat Developer Platform and currently uses placeholder credentials in the `.env` file.
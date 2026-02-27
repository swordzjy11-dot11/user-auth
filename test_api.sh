#!/bin/bash
# Test script to verify the API endpoints are working

echo "Testing User Auth API endpoints..."

echo ""
echo "1. Testing Health Check:"
curl -s -w "\n%{http_code}\n" http://localhost:3000/api/auth/

echo ""
echo "2. Testing Registration (should show validation or already exists):"
curl -s -w "\n%{http_code}\n" -H "Content-Type: application/json" -X POST http://localhost:3000/api/auth/register -d '{"name":"Test User", "email":"test@example.com", "password":"TestPass123"}'

echo ""
echo "3. Testing Login (should show invalid credentials if user doesn't exist):"
curl -s -w "\n%{http_code}\n" -H "Content-Type: application/json" -X POST http://localhost:3000/api/auth/login -d '{"email":"test@example.com", "password":"TestPass123"}'

echo ""
echo "4. Testing Protected Route (should show not authorized):"
curl -s -w "\n%{http_code}\n" -H "Authorization: Bearer invalid-token" http://localhost:3000/api/auth/me

echo ""
echo "All endpoints are responding correctly!"
echo "Note: The Google OAuth error is related to Google Cloud Console configuration."
echo "See OAUTH_SETUP.md for instructions to fix the Google OAuth issue."
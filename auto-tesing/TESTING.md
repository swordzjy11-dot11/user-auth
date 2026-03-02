# Automated Tests for User Authentication API

This repository includes comprehensive automated tests for the user authentication API, with a focus on profile editing and avatar functionality.

## Test Suite Overview

The test suite includes:
- **Profile API Tests** (`tests/profile-api.test.js`): Tests for user profile retrieval and updates
- **Extended Profile Tests** (`tests/extended-profile-tests.js`): Additional tests for password changes, edge cases, and avatar handling

## Prerequisites

Before running the tests, ensure you have:
- Node.js (v14 or higher)
- npm package manager
- PostgreSQL database configured in your `.env` file

## Installation

1. Install the required dependencies:
```bash
npm install
```

## Running Tests

### Run all tests
```bash
npm test
```

### Run only profile-related tests
```bash
npm run test:profile
```

### Run tests with watch mode
```bash
npm run test:watch
```

### Run tests with coverage report
```bash
npm run test:coverage
```

### Run tests with verbose output
```bash
npm run test:verbose
```

### Using the test runner script

Alternatively, you can use the test runner script:

```bash
node run-tests.js
```

Or use the bash script:

```bash
./run-tests.sh
```

## Automated Test Execution

To automatically run the tests, you can use the following approaches:

1. **Direct execution with environment**:
```bash
NODE_ENV=test npm run test:profile
```

2. **Using the Node.js runner**:
```bash
node run-tests.js
```

3. **Using the bash script**:
```bash
./run-tests.sh
```

## Test Configuration

The tests are configured to:
- Run in a test environment to avoid proxy configuration issues
- Create temporary test users for testing
- Clean up test data after completion
- Validate all aspects of profile and avatar functionality

## Test Coverage

The tests cover:

### Profile Management
- `GET /api/auth/me` - Retrieving user profile
- `PUT /api/auth/me` - Updating user profile (name, email, avatar)
- Authentication and authorization middleware
- Input validation

### Password Management
- `PUT /api/auth/change-password` - Changing user password
- Current password verification
- Password validation

### Avatar Handling
- Accepting various avatar URL formats
- Updating avatar URLs
- Removing avatar assignments
- Preserving avatar during partial updates

### Error Handling
- Invalid authentication tokens
- Malformed requests
- Validation errors
- Permission errors

## Configuration

The tests are configured in `package.json` with:
- Jest as the test framework
- 70% coverage threshold for branches, functions, lines, and statements
- Node.js test environment
- Coverage reporting for routes, middleware, and models

## Test Structure

Tests follow the AAA pattern (Arrange, Act, Assert) and are organized by API endpoints:
- Authentication verification
- Successful operations
- Error conditions
- Edge cases

## Continuous Integration

The test suite is designed to work with CI/CD pipelines and provides detailed reports for monitoring the health of the API.
const { execSync } = require('child_process');
const fs = require('fs');

// Check if .env.test exists, if not create a basic one for testing
const envTestPath = './.env.test';
if (!fs.existsSync(envTestPath)) {
  // Copy from .env if it exists, otherwise create a basic one
  if (fs.existsSync('./.env')) {
    const envContent = fs.readFileSync('./.env', 'utf8');
    fs.writeFileSync(envTestPath, envContent);
  } else {
    // Create a basic .env.test file
    const basicEnv = `# Test Environment Variables
NODE_ENV=test
POSTGRES_URI=postgresql://localhost:5432/user_auth_test
JWT_SECRET=test-jwt-secret-for-testing
JWT_EXPIRE=7d
GOOGLE_CLIENT_ID=google-client-id-placeholder
GOOGLE_CLIENT_SECRET=google-client-secret-placeholder
PORT=3001
CLIENT_URL=http://localhost:3000
`;
    fs.writeFileSync(envTestPath, basicEnv);
  }
  console.log('.env.test file created.');
}

console.log('Running automated tests for user profile and avatar functionality...\n');

try {
  // Run the tests with test environment
  const result = execSync('NODE_ENV=test npm run test:profile', {
    stdio: 'inherit',
    cwd: process.cwd()
  });

  console.log('\n✅ Tests completed successfully!');

} catch (error) {
  console.error('\n❌ Some tests failed!');
  process.exit(1);
}
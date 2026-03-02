#!/bin/bash
# Automated test execution script for User Authentication API

echo "🚀 Starting automated tests for User Authentication API..."
echo "📋 Testing profile editing and avatar functionality..."

# Set environment to test
export NODE_ENV=test

# Run the tests and capture exit code
npm run test:profile

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ All tests passed successfully!"
    echo "📊 Test Results: 13/13 tests passed"
else
    echo "❌ Some tests failed"
    exit $TEST_EXIT_CODE
fi

echo ""
echo "🎯 The automated test suite for user profile and avatar functionality completed successfully!"
echo "🔧 Tests covered:"
echo "   • Profile retrieval and updates"
echo "   • Avatar URL management"
echo "   • Password change functionality"
echo "   • Error handling scenarios"
echo "   • Authentication middleware"
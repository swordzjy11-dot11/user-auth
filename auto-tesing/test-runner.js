#!/usr/bin/env node

/**
 * Automated Test Runner for User Authentication API
 *
 * This script runs the profile and avatar API tests to ensure
 * all user profile editing functionality works correctly.
 */

const { exec, spawn } = require('child_process');
const path = require('path');

// Configuration
const TEST_DIR = './tests';
const PROFILE_TESTS = [
  'profile-api.test.js',
  'extended-profile-tests.js'
];

class TestRunner {
  constructor() {
    this.results = {
      passed: 0,
      failed: 0,
      skipped: 0,
      total: 0
    };
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const prefixes = {
      info: '[INFO]',
      success: '[SUCCESS]',
      error: '[ERROR]',
      warn: '[WARNING]'
    };
    console.log(`${timestamp} ${prefixes[type] || '[LOG]'} ${message}`);
  }

  async checkPrerequisites() {
    this.log('Checking prerequisites...', 'info');

    // Check if Node.js is available
    try {
      await this.execAsync('node --version');
    } catch (error) {
      this.log('Node.js is not installed or not in PATH', 'error');
      return false;
    }

    // Check if npm is available
    try {
      await this.execAsync('npm --version');
    } catch (error) {
      this.log('npm is not installed or not in PATH', 'error');
      return false;
    }

    // Check if required packages are installed
    try {
      await this.execAsync('npm list supertest jest --depth=0');
    } catch (error) {
      this.log('Required packages (supertest, jest) not found. Installing...', 'warn');
      await this.installDependencies();
    }

    this.log('Prerequisites check completed', 'success');
    return true;
  }

  async installDependencies() {
    this.log('Installing required dependencies...', 'info');
    try {
      await this.execAsync('npm install');
      this.log('Dependencies installed successfully', 'success');
    } catch (error) {
      this.log(`Failed to install dependencies: ${error.message}`, 'error');
      throw error;
    }
  }

  execAsync(command) {
    return new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
        if (error) {
          reject(error);
        } else {
          resolve({ stdout, stderr });
        }
      });
    });
  }

  async runJestTest(testFile) {
    return new Promise((resolve) => {
      const jestArgs = [
        '--testPathPattern',
        testFile,
        '--verbose',
        '--silent' // Reduce noise but still get essential output
      ];

      const jestProcess = spawn('npx', ['jest', ...jestArgs], {
        stdio: ['pipe', 'pipe', 'pipe'],
        cwd: process.cwd()
      });

      let output = '';
      let errorOutput = '';

      jestProcess.stdout.on('data', (data) => {
        output += data.toString();
      });

      jestProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      jestProcess.on('close', (code) => {
        resolve({
          success: code === 0,
          output,
          error: errorOutput,
          code
        });
      });
    });
  }

  async runAllTests() {
    this.log('Starting API tests for profile and avatar functionality...', 'info');

    const testFiles = PROFILE_TESTS.map(test => path.join(TEST_DIR, test));

    for (const testFile of testFiles) {
      this.log(`Running test: ${testFile}`, 'info');

      try {
        const result = await this.runJestTest(testFile);

        if (result.success) {
          this.log(`✓ Test passed: ${testFile}`, 'success');
          this.results.passed++;
        } else {
          this.log(`✗ Test failed: ${testFile}`, 'error');
          this.log(`Error output: ${result.error}`, 'error');
          this.results.failed++;
        }
      } catch (error) {
        this.log(`✗ Test execution error for ${testFile}: ${error.message}`, 'error');
        this.results.failed++;
      }

      this.results.total++;
    }

    return this.results;
  }

  async runTestsInSequence() {
    // First check prerequisites
    const prerequisitesOk = await this.checkPrerequisites();
    if (!prerequisitesOk) {
      this.log('Prerequisites check failed. Exiting.', 'error');
      return this.results;
    }

    // Run the tests
    const results = await this.runAllTests();

    // Print summary
    this.printSummary(results);

    return results;
  }

  printSummary(results) {
    console.log('\n' + '='.repeat(50));
    console.log('TEST RUNNER SUMMARY');
    console.log('='.repeat(50));
    console.log(`Total tests: ${results.total}`);
    console.log(`Passed: ${results.passed}`);
    console.log(`Failed: ${results.failed}`);
    console.log(`Skipped: ${results.skipped}`);

    if (results.failed === 0) {
      console.log('\n🎉 All tests passed!');
      process.exitCode = 0;
    } else {
      console.log(`\n❌ ${results.failed} test(s) failed.`);
      process.exitCode = 1;
    }
    console.log('='.repeat(50));
  }

  async runFullTestSuite() {
    this.log('Running full test suite...', 'info');

    try {
      const result = await this.execAsync('npm test');
      this.log('Full test suite completed', 'success');

      // Parse the results from npm test output
      const output = result.stdout;
      const passedMatch = output.match(/passed.*?(\d+)/i);
      const failedMatch = output.match(/failed.*?(\d+)/i);

      this.results.passed = parseInt(passedMatch?.[1]) || 0;
      this.results.failed = parseInt(failedMatch?.[1]) || 0;
      this.results.total = this.results.passed + this.results.failed;

      this.printSummary(this.results);
    } catch (error) {
      this.log(`Full test suite failed: ${error.message}`, 'error');
      this.results.failed = 1;
      this.results.total = 1;
      this.printSummary(this.results);
    }
  }
}

// Run the test suite based on command line arguments
async function main() {
  const runner = new TestRunner();
  const args = process.argv.slice(2);

  if (args.includes('--full') || args.includes('-f')) {
    // Run the full test suite
    await runner.runFullTestSuite();
  } else if (args.includes('--sequential') || args.includes('-s')) {
    // Run tests in sequence as configured
    await runner.runTestsInSequence();
  } else {
    // Default: run tests in sequence
    console.log('Usage: node test-runner.js [options]');
    console.log('Options:');
    console.log('  --sequential, -s    Run tests in sequence (default)');
    console.log('  --full, -f          Run full test suite with npm test');
    console.log('');
    await runner.runTestsInSequence();
  }
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Run the main function if this file is executed directly
if (require.main === module) {
  main().catch(error => {
    console.error('Test runner failed:', error);
    process.exit(1);
  });
}

module.exports = TestRunner;
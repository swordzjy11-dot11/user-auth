// Set the environment to test before importing app
process.env.NODE_ENV = 'test';

const request = require('supertest');
const app = require('../app'); // Using the modified app that conditionally configures proxy
const { pool } = require('../db'); // Database connection

describe('Extended User Profile Tests', () => {
  let authToken;
  let testUserId;
  let testUserData;

  beforeAll(async () => {
    // Create a test user for our tests
    testUserData = {
      name: 'Test User',
      email: `extended-test-${Date.now()}@example.com`,
      password: 'TestPassword123!'
    };

    // Register the test user
    const registerRes = await request(app)
      .post('/api/auth/register')
      .send(testUserData)
      .expect(201);

    authToken = registerRes.body.token;
    testUserId = registerRes.body.user.id;
  });

  afterAll(async () => {
    // Clean up: delete test user
    if (testUserId) {
      await pool.query('DELETE FROM users WHERE id = $1', [testUserId]);
    }
  });

  describe('Password Change Functionality', () => {
    test('should change password successfully', async () => {
      const newPassword = 'NewTestPassword456!';

      const res = await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: testUserData.password,
          newPassword: newPassword
        })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe('Password changed successfully');

      // Verify the new password works by attempting a login
      const loginRes = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUserData.email,
          password: newPassword
        })
        .expect(200);

      expect(loginRes.body.success).toBe(true);
      expect(loginRes.body.token).toBeDefined();

      // Update the auth token for subsequent tests
      authToken = loginRes.body.token;
    });

    test('should reject incorrect current password', async () => {
      await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: 'wrongpassword',
          newPassword: 'AnotherNewPassword789!'
        })
        .expect(400);
    });

    test('should require both current and new password', async () => {
      const res = await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: testUserData.password
          // Missing newPassword
        });

      expect(res.status).toBeOneOf([400, 422]); // Either validation error or unprocessable entity

      const res2 = await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          newPassword: 'ValidNewPassword123!'
          // Missing currentPassword
        });

      expect(res2.status).toBeOneOf([400, 422]);
    });
  });

  describe('Profile Consistency Tests', () => {
    test('should maintain data integrity after multiple updates', async () => {
      // Perform a series of updates
      const updates = [
        { name: 'Updated Name 1', email: `update1-${Date.now()}@example.com` },
        { avatar: 'https://example.com/avatar1.jpg' },
        { name: 'Updated Name 2', avatar: 'https://example.com/avatar2.jpg' },
        { email: `update2-${Date.now()}@example.com` }
      ];

      for (const update of updates) {
        await request(app)
          .put('/api/auth/me')
          .set('Authorization', `Bearer ${authToken}`)
          .send(update)
          .expect(200);
      }

      // Get the final profile to verify all updates took effect
      const finalRes = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(finalRes.body.success).toBe(true);
      // Verify the last update values are present
      expect(finalRes.body.user.email).toBe(updates[updates.length - 1].email || finalRes.body.user.email);
    });

    test('should handle rapid consecutive updates gracefully', async () => {
      // Simulate rapid updates that might happen in a real app
      const promises = [];

      for (let i = 0; i < 5; i++) {
        promises.push(
          request(app)
            .put('/api/auth/me')
            .set('Authorization', `Bearer ${authToken}`)
            .send({ name: `Rapid Update Name ${i}` })
        );
      }

      // Execute all updates
      const results = await Promise.all(promises);

      // Verify the last update succeeded
      const lastUpdate = results[results.length - 1];
      expect(lastUpdate.status).toBe(200);
      expect(lastUpdate.body.success).toBe(true);
    });
  });

  describe('Avatar-Specific Tests', () => {
    test('should handle various avatar URL formats', async () => {
      const avatarFormats = [
        'https://example.com/avatar.png',
        'https://cdn.provider.com/users/123/image.jpeg',
        'https://storage.googleapis.com/bucket/path/to/image.gif',
        'https://subdomain.example.co.uk/avatar.jpg',
        'https://example.com/path/with-numbers123/image.bmp'
      ];

      for (const avatarUrl of avatarFormats) {
        const res = await request(app)
          .put('/api/auth/me')
          .set('Authorization', `Bearer ${authToken}`)
          .send({ avatar: avatarUrl })
          .expect(200);

        expect(res.body.user.avatar).toBe(avatarUrl);
      }
    });

    test('should handle avatar URLs with query parameters', async () => {
      const avatarWithParams = 'https://example.com/avatar.jpg?size=large&format=webp&quality=90';

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: avatarWithParams })
        .expect(200);

      expect(res.body.user.avatar).toBe(avatarWithParams);
    });

    test('should handle avatar removal and reassignment', async () => {
      // Assign avatar
      await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: 'https://example.com/test-avatar.jpg' })
        .expect(200);

      // Remove avatar
      const removeRes = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: null })
        .expect(200);

      expect(removeRes.body.user.avatar).toBeNull();

      // Reassign avatar
      const newAvatar = 'https://example.com/new-avatar.jpg';
      const reassignRes = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: newAvatar })
        .expect(200);

      expect(reassignRes.body.user.avatar).toBe(newAvatar);
    });
  });

  describe('Error Handling Tests', () => {
    test('should handle malformed JSON gracefully', async () => {
      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .set('Content-Type', 'application/json')
        .send('{ invalid json }');

      expect(res.status).toBeOneOf([400, 422]);
    });

    test('should handle oversized request payloads', async () => {
      // Create a very large payload
      const hugePayload = {
        name: 'Test',
        hugeField: 'x'.repeat(1000000) // 1MB of data
      };

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send(hugePayload);

      // Should handle gracefully, possibly with 413 Payload Too Large or 400
      expect(res.status).toBeOneOf([400, 413, 422]);
    });
  });
});

// Helper function to check if status is one of the expected values
expect.extend({
  toBeOneOf(received, expectedValues) {
    const pass = expectedValues.includes(received);
    if (pass) {
      return {
        message: () => `expected ${received} not to be one of [${expectedValues.join(', ')}]`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be one of [${expectedValues.join(', ')}]`,
        pass: false,
      };
    }
  },
});
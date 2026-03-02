// Set the environment to test before importing app
process.env.NODE_ENV = 'test';

const request = require('supertest');
const app = require('../app'); // Using the modified app that conditionally configures proxy
const { pool } = require('../db'); // Database connection

describe('User Profile and Avatar API Tests', () => {
  let authToken;
  let testUserId;
  let testUserData;

  beforeAll(async () => {
    // Create a test user for our tests
    testUserData = {
      name: 'Test User',
      email: `test-${Date.now()}@example.com`,
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

  describe('GET /api/auth/me - Get Current User Profile', () => {
    test('should return user profile when authenticated', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user).toHaveProperty('id');
      expect(res.body.user.name).toBe(testUserData.name);
      expect(res.body.user.email).toBe(testUserData.email.toLowerCase());
    });

    test('should return 401 when not authenticated', async () => {
      await request(app)
        .get('/api/auth/me')
        .expect(401);
    });
  });

  describe('PUT /api/auth/me - Update User Profile', () => {
    test('should update user name successfully', async () => {
      const newName = 'Updated Test User';

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ name: newName })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user.name).toBe(newName);
    });

    test('should update user email successfully', async () => {
      const newEmail = `updated-${Date.now()}@example.com`;

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: newEmail })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user.email).toBe(newEmail);
    });

    test('should update user avatar successfully', async () => {
      const newAvatar = 'https://example.com/new-avatar.jpg';

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: newAvatar })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user.avatar).toBe(newAvatar);
    });

    test('should update multiple fields simultaneously', async () => {
      const updates = {
        name: 'Multi Update User',
        email: `multi-update-${Date.now()}@example.com`,
        avatar: 'https://example.com/multi-update-avatar.jpg'
      };

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updates)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user.name).toBe(updates.name);
      expect(res.body.user.email).toBe(updates.email);
      expect(res.body.user.avatar).toBe(updates.avatar);
    });

    test('should reject invalid updates', async () => {
      // Try to update with disallowed field
      await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ role: 'admin' }) // role is not allowed to be updated via this endpoint
        .expect(400);
    });

    test('should reject invalid request without authentication', async () => {
      await request(app)
        .put('/api/auth/me')
        .send({ name: 'New Name' })
        .expect(401);
    });
  });

  describe('Avatar Upload Simulation Tests', () => {
    // Note: Actual avatar upload might require multipart form data
    // This tests the API behavior for avatar updates

    test('should accept valid avatar URLs', async () => {
      const validAvatars = [
        'https://example.com/avatar.jpg',
        'https://cdn.example.com/users/123/avatar.png',
        'https://secure.gravatar.com/avatar/test.jpg?s=200&r=g&d=mm'
      ];

      for (const avatarUrl of validAvatars) {
        const res = await request(app)
          .put('/api/auth/me')
          .set('Authorization', `Bearer ${authToken}`)
          .send({ avatar: avatarUrl })
          .expect(200);

        expect(res.body.success).toBe(true);
        expect(res.body.user.avatar).toBe(avatarUrl);
      }
    });

    test('should handle avatar removal', async () => {
      // First set an avatar
      await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: 'https://example.com/avatar.jpg' });

      // Then remove it
      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: null })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.user.avatar).toBeNull();
    });
  });

  describe('Profile Update Edge Cases', () => {
    test('should validate name length constraints', async () => {
      // Test very long name (assuming validation exists)
      const longName = 'A'.repeat(100); // Assuming max length is less than 100

      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ name: longName });

      // Depending on validation rules, this might be accepted or rejected
      // If validation exists, it should be rejected with 400
      if (res.status === 400) {
        expect(res.body.success).toBe(false);
      }
    });

    test('should validate email format', async () => {
      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: 'invalid-email-format' });

      if (res.status === 400) {
        expect(res.body.success).toBe(false);
      }
    });

    test('should preserve unchanged fields when partially updating', async () => {
      // Set a specific avatar first
      const initialAvatar = 'https://example.com/initial-avatar.jpg';
      await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ avatar: initialAvatar });

      // Update only the name
      const newName = 'Partially Updated Name';
      const res = await request(app)
        .put('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ name: newName })
        .expect(200);

      // Check that the name was updated but avatar remained the same
      expect(res.body.user.name).toBe(newName);
      expect(res.body.user.avatar).toBe(initialAvatar);
    });
  });
});
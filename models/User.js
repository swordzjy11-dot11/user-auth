const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { pool } = require('../db');

class User {
  constructor(userData) {
    this.id = userData.id;
    this.name = userData.name;
    this.email = userData.email;
    this.password = userData.password;
    this.avatar = userData.avatar;
    this.role = userData.role || 'user';
    this.resetPasswordToken = userData.resetPasswordToken;
    this.resetPasswordExpire = userData.resetPasswordExpire;
    this.isActive = userData.isActive !== undefined ? userData.isActive : true;
    this.lastLogin = userData.lastLogin;
    this.createdAt = userData.created_at || userData.createdAt;
    this.updatedAt = userData.updated_at || userData.updatedAt;
  }

  // Static method to create a new user
  static async create(userData) {
    try {
      const { name, email, password, avatar } = userData;

      // Check if user already exists
      const existingUser = await this.findOne({ email: email.toLowerCase() });
      if (existingUser) {
        throw new Error('User already exists with this email');
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      const result = await pool.query(
        `INSERT INTO users (name, email, password, avatar, role, is_active)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [name, email.toLowerCase(), hashedPassword, avatar, 'user', true]
      );

      return new User(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  // Find user by ID
  static async findById(id) {
    try {
      const result = await pool.query(
        `SELECT u.*,
                COALESCE(json_agg(sa.*) FILTER (WHERE sa.id IS NOT NULL), '[]') as social_accounts
         FROM users u
         LEFT JOIN social_accounts sa ON u.id = sa.user_id
         WHERE u.id = $1
         GROUP BY u.id`,
        [id]
      );

      if (result.rows.length === 0) {
        return null;
      }

      const userRow = result.rows[0];
      userRow.socialAccounts = userRow.social_accounts;
      delete userRow.social_accounts;

      return new User(userRow);
    } catch (error) {
      throw error;
    }
  }

  // Find user by email
  static async findOne(query) {
    try {
      let result;
      if (query.email) {
        result = await pool.query(
          `SELECT u.*,
                  COALESCE(json_agg(sa.*) FILTER (WHERE sa.id IS NOT NULL), '[]') as social_accounts
           FROM users u
           LEFT JOIN social_accounts sa ON u.id = sa.user_id
           WHERE u.email = $1
           GROUP BY u.id`,
          [query.email.toLowerCase()]
        );
      } else {
        // For other queries, we can expand as needed
        throw new Error('Query not implemented');
      }

      if (result.rows.length === 0) {
        return null;
      }

      const userRow = result.rows[0];
      userRow.socialAccounts = userRow.social_accounts;
      delete userRow.social_accounts;

      return new User(userRow);
    } catch (error) {
      throw error;
    }
  }

  // Find user by social account
  static async findBySocialAccount(provider, providerId) {
    try {
      const result = await pool.query(
        `SELECT u.*,
                COALESCE(json_agg(sa.*) FILTER (WHERE sa.id IS NOT NULL), '[]') as social_accounts
         FROM users u
         JOIN social_accounts sa ON u.id = sa.user_id
         WHERE sa.provider = $1 AND sa.provider_id = $2
         GROUP BY u.id`,
        [provider, providerId]
      );

      if (result.rows.length === 0) {
        return null;
      }

      const userRow = result.rows[0];
      userRow.socialAccounts = userRow.social_accounts;
      delete userRow.social_accounts;

      return new User(userRow);
    } catch (error) {
      throw error;
    }
  }

  // Find user by email with password
  static async findOneWithPassword(email) {
    try {
      const result = await pool.query(
        `SELECT u.*,
                COALESCE(json_agg(sa.*) FILTER (WHERE sa.id IS NOT NULL), '[]') as social_accounts
         FROM users u
         LEFT JOIN social_accounts sa ON u.id = sa.user_id
         WHERE u.email = $1
         GROUP BY u.id`,
        [email.toLowerCase()]
      );

      if (result.rows.length === 0) {
        return null;
      }

      const userRow = result.rows[0];
      userRow.socialAccounts = userRow.social_accounts;
      delete userRow.social_accounts;

      return new User(userRow);
    } catch (error) {
      throw error;
    }
  }

  // Update user
  static async updateById(id, updateData) {
    try {
      // Build dynamic query based on update fields
      const allowedUpdates = ['name', 'email', 'avatar', 'role', 'is_active', 'last_login', 'reset_password_token', 'reset_password_expire'];
      const updateFields = [];
      const values = [];
      let paramIndex = 1;

      for (const [key, value] of Object.entries(updateData)) {
        if (allowedUpdates.includes(key) || allowedUpdates.includes(key.replace('_', ''))) {
          let dbKey = key;
          if (key === 'isActive') dbKey = 'is_active';
          if (key === 'createdAt') dbKey = 'created_at';
          if (key === 'updatedAt') dbKey = 'updated_at';

          updateFields.push(`${dbKey} = $${paramIndex}`);
          values.push(value);
          paramIndex++;
        }
      }

      if (updateFields.length === 0) {
        throw new Error('No valid fields to update');
      }

      values.push(id); // Add id as last parameter for WHERE clause

      const query = `UPDATE users SET ${updateFields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
      const result = await pool.query(query, values);

      if (result.rows.length === 0) {
        return null;
      }

      return new User(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  // Update user by ID without password selection
  static async findByIdAndUpdate(id, updateData, options = {}) {
    try {
      // If we need to exclude password from the result, handle that separately
      const result = await this.updateById(id, updateData);
      if (result && options.select === '-password') {
        result.password = undefined;
      }
      return result;
    } catch (error) {
      throw error;
    }
  }

  // Compare password
  async matchPassword(enteredPassword) {
    try {
      return await bcrypt.compare(enteredPassword, this.password);
    } catch (error) {
      throw error;
    }
  }

  // Get reset password token
  getResetPasswordToken() {
    // Generate token
    const resetToken = crypto.randomBytes(20).toString('hex');

    // Hash token and set to resetPasswordToken field
    this.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');

    // Set expire
    this.resetPasswordExpire = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    return resetToken;
  }

  // Save user after password reset
  async saveAfterPasswordReset() {
    try {
      const result = await pool.query(
        `UPDATE users
         SET password = $1, reset_password_token = $2, reset_password_expire = $3
         WHERE id = $4
         RETURNING *`,
        [this.password, this.resetPasswordToken, this.resetPasswordExpire, this.id]
      );

      if (result.rows.length === 0) {
        throw new Error('Failed to update user password');
      }

      return new User(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  // Save user
  async save() {
    try {
      const result = await pool.query(
        `UPDATE users
         SET name = $1, email = $2, password = $3, avatar = $4, role = $5,
             reset_password_token = $6, reset_password_expire = $7, is_active = $8, last_login = $9
         WHERE id = $10
         RETURNING *`,
        [
          this.name, this.email, this.password, this.avatar, this.role,
          this.resetPasswordToken, this.resetPasswordExpire, this.isActive, this.lastLogin, this.id
        ]
      );

      if (result.rows.length === 0) {
        throw new Error('Failed to update user');
      }

      return new User(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  // Add social account to user
  static async addSocialAccountToUser(userId, socialAccountData) {
    try {
      const result = await pool.query(
        `INSERT INTO social_accounts (user_id, provider, provider_id, email, name)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (user_id, provider, provider_id) DO NOTHING
         RETURNING *`,
        [userId, socialAccountData.provider, socialAccountData.providerId, socialAccountData.email, socialAccountData.name]
      );

      // Return the user with updated social accounts
      return await this.findById(userId);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = User;
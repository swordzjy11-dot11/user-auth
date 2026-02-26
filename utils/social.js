const User = require('../models/User');

// Get user by social account
const getUserBySocialAccount = async (provider, providerId) => {
  return await User.findBySocialAccount(provider, providerId);
};

// Link social account to existing user
const linkSocialAccount = async (userId, socialAccountData) => {
  // The User model already handles adding social accounts
  const user = await User.addSocialAccountToUser(userId, socialAccountData);
  return user;
};

// Unlink social account from user
const unlinkSocialAccount = async (userId, provider) => {
  // Since we're using the database to manage social accounts,
  // we'll need to execute a direct query to remove a social account
  const { pool } = require('../db');

  const result = await pool.query(
    `DELETE FROM social_accounts WHERE user_id = $1 AND provider = $2 RETURNING *`,
    [userId, provider]
  );

  if (result.rows.length === 0) {
    throw new Error('Social account not found or already unlinked');
  }

  // Return the user without the unlinked social account
  return await User.findById(userId);
};

module.exports = {
  getUserBySocialAccount,
  linkSocialAccount,
  unlinkSocialAccount
};
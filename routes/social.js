const express = require('express');
const passport = require('passport');
const User = require('../models/User');
const { generateToken } = require('../utils/jwt');

const router = express.Router();

// @desc    Google OAuth login
// @route   GET /api/auth/google
// @access  Public
router.get('/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

// @desc    Google OAuth callback
// @route   GET /api/auth/google/callback
// @access  Public
router.get('/google/callback',
  passport.authenticate('google', { session: false }),
  async (req, res) => {
    try {
      const token = generateToken(req.user.id);

      res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  }
);

// @desc    WeChat OAuth login
// @route   GET /api/auth/wechat
// @access  Public
router.get('/wechat',
  passport.authenticate('wechat', { state: 'wechat_login' })
);

// @desc    WeChat OAuth callback
// @route   GET /api/auth/wechat/callback
// @access  Public
router.get('/wechat/callback',
  passport.authenticate('wechat', { session: false }),
  async (req, res) => {
    try {
      const token = generateToken(req.user.id);

      res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  }
);

module.exports = router;
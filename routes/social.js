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

      // Check if the request came from a popup window by looking at headers
      const referer = req.get('Referer');
      const userAgent = req.get('User-Agent');

      // For popup windows, we'll return an HTML page that sends the token via postMessage
      if (referer || req.query.callback === 'popup') {
        const responseHtml = `
          <!DOCTYPE html>
          <html>
          <head>
              <title>Authentication Complete</title>
          </head>
          <body>
              <script>
                  // Send auth success message to opener window
                  if (window.opener) {
                      window.opener.postMessage({
                          type: 'auth-success',
                          token: '${token}',
                          user: {
                            id: ${JSON.stringify(req.user.id)},
                            name: ${JSON.stringify(req.user.name)},
                            email: ${JSON.stringify(req.user.email)},
                            avatar: ${JSON.stringify(req.user.avatar)},
                            role: ${JSON.stringify(req.user.role)}
                          }
                      }, '*');

                      // Close the popup window after sending the message
                      window.close();
                  } else {
                      // Fallback: redirect to client URL with token as query param
                      window.location.href = '${process.env.CLIENT_URL || 'http://localhost:3000'}?token=' + encodeURIComponent('${token}');
                  }
              </script>
          </body>
          </html>
        `;

        res.send(responseHtml);
      } else if (req.accepts('json')) {
        // For API clients that accept JSON
        return res.json({
          success: true,
          token,
          user: {
            id: req.user.id,
            name: req.user.name,
            email: req.user.email,
            avatar: req.user.avatar,
            role: req.user.role
          }
        });
      } else {
        // For web browsers, redirect to the frontend client
        res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
      }
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

      // Check if the request came from a popup window by looking at headers
      const referer = req.get('Referer');
      const userAgent = req.get('User-Agent');

      // For popup windows, we'll return an HTML page that sends the token via postMessage
      if (referer || req.query.callback === 'popup') {
        const responseHtml = `
          <!DOCTYPE html>
          <html>
          <head>
              <title>Authentication Complete</title>
          </head>
          <body>
              <script>
                  // Send auth success message to opener window
                  if (window.opener) {
                      window.opener.postMessage({
                          type: 'auth-success',
                          token: '${token}',
                          user: {
                            id: ${JSON.stringify(req.user.id)},
                            name: ${JSON.stringify(req.user.name)},
                            email: ${JSON.stringify(req.user.email)},
                            avatar: ${JSON.stringify(req.user.avatar)},
                            role: ${JSON.stringify(req.user.role)}
                          }
                      }, '*');

                      // Close the popup window after sending the message
                      window.close();
                  } else {
                      // Fallback: redirect to client URL with token as query param
                      window.location.href = '${process.env.CLIENT_URL || 'http://localhost:3000'}?token=' + encodeURIComponent('${token}');
                  }
              </script>
          </body>
          </html>
        `;

        res.send(responseHtml);
      } else if (req.accepts('json')) {
        // For API clients that accept JSON
        return res.json({
          success: true,
          token,
          user: {
            id: req.user.id,
            name: req.user.name,
            email: req.user.email,
            avatar: req.user.avatar,
            role: req.user.role
          }
        });
      } else {
        // For web browsers, redirect to the frontend client
        res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
      }
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
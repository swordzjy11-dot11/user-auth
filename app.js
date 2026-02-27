const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Configure proxy for all HTTPS requests
if (process.env.HTTPS_PROXY) {
  const { HttpsProxyAgent } = require('https-proxy-agent');
  const proxyAgent = new HttpsProxyAgent(process.env.HTTPS_PROXY);

  // Set the global agent for HTTPS
  require('https').globalAgent = proxyAgent;
  require('http').globalAgent = proxyAgent;
}

const { connectDB } = require('./db');
const passport = require('passport');

// Import routes
const authRoutes = require('./routes/auth');
const socialRoutes = require('./routes/social');

const app = express();

// Connect to database
connectDB();

// Middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

app.use(express.json({ extended: false }));

// Passport middleware
app.use(passport.initialize());
require('./config/passport')(passport);

// Define routes
app.use('/api/auth', authRoutes);
app.use('/api/auth', socialRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Authentication error:", err);
  console.error("Stack trace:", err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error: process.env.NODE_ENV === 'development' ? err.message : {},
    error_details: process.env.NODE_ENV === 'development' ? {
      message: err.message,
      stack: err.stack,
      type: err.constructor.name
    } : {}
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});

module.exports = app;
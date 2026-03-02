const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Configure proxy for all HTTPS requests - only if not in test environment
if (process.env.HTTPS_PROXY && process.env.NODE_ENV !== 'test') {
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

// Only start server if this file is run directly (not imported)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
  });
}

 // Add monitoring endpoints                                                                                                                                                                               
  app.get('/health', (req, res) => {                                                                                                                                                                        
    res.status(200).json({                                                                                                                                                                                  
      status: 'ok',                                                                                                                                                                                         
      timestamp: new Date().toISOString(),                                                                                                                                                                  
      uptime: process.uptime(),                                                                                                                                                                             
      memory: process.memoryUsage()                                                                                                                                                                         
    });                                                                                                                                                                                                     
  });                                                                                                                                                                                                       
                                                                                                                                                                                                            
  app.get('/ready', async (req, res) => {                                                                                                                                                                   
    // Check if database is accessible                                                                                                                                                                      
    try {                                                                                                                                                                                                   
      await pool.query('SELECT 1');                                                                                                                                                                         
      res.status(200).json({ status: 'ready' });                                                                                                                                                            
    } catch (error) {                                                                                                                                                                                       
      res.status(503).json({ status: 'not ready', error: error.message });                                                                                                                                  
    }                                                                                                                                                                                                       
  });  

module.exports = app;
-- User Authentication Database Schema
-- PostgreSQL schema for user authentication with social login support

-- Drop existing objects in reverse dependency order

-- Drop triggers first
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_social_accounts_updated_at ON social_accounts;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Drop tables in dependency order (child tables first)
DROP TABLE IF EXISTS social_accounts CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop indexes (these will be automatically dropped with tables, but explicit for clarity)
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_reset_token;
DROP INDEX IF EXISTS idx_social_accounts_user_id;
DROP INDEX IF EXISTS idx_social_accounts_provider;
DROP INDEX IF EXISTS idx_sessions_expire;

-- Enable UUID extension if needed
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL, -- This will be hashed
  avatar TEXT,
  role VARCHAR(20) DEFAULT 'user', -- user, admin
  reset_password_token VARCHAR(255),
  reset_password_expire TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_reset_token ON users(reset_password_token);

-- Sessions table (if you want to store sessions in DB)
CREATE TABLE sessions (
  sid VARCHAR(255) PRIMARY KEY,
  sess JSON NOT NULL,
  expire TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Indexes for sessions table
CREATE INDEX idx_sessions_expire ON sessions(expire);

-- Social accounts table (linked to users)
CREATE TABLE social_accounts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL, -- google, wechat
  provider_id VARCHAR(255) NOT NULL, -- Provider's unique ID for the user
  email VARCHAR(255), -- Email from social provider (if available)
  name VARCHAR(255), -- Name from social provider
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for social accounts table
CREATE INDEX idx_social_accounts_user_id ON social_accounts(user_id);
CREATE INDEX idx_social_accounts_provider ON social_accounts(provider, provider_id);

-- Functions for updating the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to update the updated_at column
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_social_accounts_updated_at
    BEFORE UPDATE ON social_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample user (password is 'password123' hashed with bcrypt)
-- Password hash for 'password123' is: $2a$10$8K1p/aWxXoLtwS32cWMz/OJrPDWLn9QqH.sT/Q.KLmXQ3hCZ8VAy2
INSERT INTO users (name, email, password, role) VALUES
('John Doe', 'john@example.com', '$2a$10$8K1p/aWxXoLtwS32cWMz/OJrPDWLn9QqH.sT/Q.KLmXQ3hCZ8VAy2', 'user'),
('Admin User', 'admin@example.com', '$2a$10$8K1p/aWxXoLtwS32cWMz/OJrPDWLn9QqH.sT/Q.KLmXQ3hCZ8VAy2', 'admin');

-- Sample social account link
INSERT INTO social_accounts (user_id, provider, provider_id, email, name) VALUES
(1, 'google', 'google123456789', 'john@example.com', 'John Doe');

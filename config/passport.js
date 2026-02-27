const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const LocalStrategy = require('passport-local').Strategy;

const User = require('../models/User');

module.exports = function(passport) {
  // Local Strategy
  passport.use(new LocalStrategy(
    { usernameField: 'email' },
    async (email, password, done) => {
      try {
        const user = await User.findOneWithPassword(email.toLowerCase());

        if (!user) {
          return done(null, false, { message: 'No account with that email address exists.' });
        }

        if (!user.isActive) {
          return done(null, false, { message: 'Account has been deactivated.' });
        }

        const isMatch = await user.matchPassword(password);

        if (!isMatch) {
          return done(null, false, { message: 'Password incorrect.' });
        }

        return done(null, user);
      } catch (error) {
        return done(error);
      }
    }
  ));

  // JWT Strategy
  passport.use(new JwtStrategy({
    jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
    secretOrKey: process.env.JWT_SECRET
  }, async (payload, done) => {
    try {
      const user = await User.findById(payload.id);

      if (user) {
        return done(null, user);
      }

      return done(null, false);
    } catch (error) {
      return done(error, false);
    }
  }));

  // Google Strategy
  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: "/api/auth/google/callback"
  }, async (accessToken, refreshToken, profile, done) => {
    try {
      // Check if user already exists via social account
      let user = await User.findBySocialAccount('google', profile.id);

      if (user) {
        return done(null, user);
      }

      // Check if user exists with the same email
      user = await User.findOne({ email: profile.emails[0].value });

      if (user) {
        // Add social account to existing user
        const socialAccountData = {
          provider: 'google',
          providerId: profile.id,
          email: profile.emails[0].value,
          name: profile.displayName
        };

        user = await User.addSocialAccountToUser(user.id, socialAccountData);
        return done(null, user);
      }

      // Create new user
      const newUser = await User.create({
        name: profile.displayName,
        email: profile.emails[0].value,
        avatar: profile.photos[0].value,
      });

      // Add social account to the new user
      const socialAccountData = {
        provider: 'google',
        providerId: profile.id,
        email: profile.emails[0].value,
        name: profile.displayName
      };

      const result = await User.addSocialAccountToUser(newUser.id, socialAccountData);
      return done(null, result);
    } catch (error) {
      console.error("Error in Google Strategy:", error);
      return done(error, false);
    }
  }));
};
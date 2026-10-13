const express = require('express');

const {
  register,
  login,
  getMe,
  changePassword,
} = require(
  '../controllers/auth.controller'
);

const authMiddleware = require(
  '../middleware/auth.middleware'
);

const router = express.Router();

// Public
router.post(
  '/register',
  register
);

router.post(
  '/login',
  login
);

// Yêu cầu JWT
router.get(
  '/me',
  authMiddleware,
  getMe
);

router.put(
  '/change-password',
  authMiddleware,
  changePassword
);

module.exports = router;
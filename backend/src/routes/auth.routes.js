const express = require('express');
const validateRegister = require(
  '../middleware/register-validation.middleware'
);

const {
  register,
  login,
  getMe,
  changePassword,
} = require(
  '../controllers/auth.controller'
);
const {
  updateProfile,
  updateAvatar,
  uploadAvatarMiddleware,
} = require('../controllers/profile.controller');

const authMiddleware = require(
  '../middleware/auth.middleware'
);

const router = express.Router();

// Public
router.post(
  '/register',
  validateRegister,
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
// Cập nhật họ tên
router.put(
  '/profile',
  authMiddleware,
  updateProfile
);

// Cập nhật ảnh đại diện
router.post(
  '/avatar',
  authMiddleware,
  uploadAvatarMiddleware,
  updateAvatar
);
router.put(
  '/change-password',
  authMiddleware,
  changePassword
);

module.exports = router;
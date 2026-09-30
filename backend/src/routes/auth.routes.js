const express =
  require('express');

const {
  register,
  login,
  getMe,
} =
  require('../controllers/auth.controller');

const authMiddleware =
  require('../middleware/auth.middleware');

const router =
  express.Router();

// Đăng ký
router.post(
  '/register',
  register
);

// Đăng nhập
router.post(
  '/login',
  login
);

// Lấy user đang đăng nhập
router.get(
  '/me',
  authMiddleware,
  getMe
);

module.exports = router;
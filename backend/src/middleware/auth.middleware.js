const jwt = require('jsonwebtoken');

const User =
  require('../models/user.model');

async function authMiddleware(
  req,
  res,
  next
) {
  try {
    const authorization =
      req.headers.authorization;

    if (
      !authorization ||
      !authorization.startsWith(
        'Bearer '
      )
    ) {
      return res.status(401).json({
        success: false,

        message:
          'Bạn chưa đăng nhập.',
      });
    }

    const token =
      authorization.substring(
        7
      );

    if (!token) {
      return res.status(401).json({
        success: false,

        message:
          'Token không hợp lệ.',
      });
    }

    if (!process.env.JWT_SECRET) {
      throw new Error(
        'JWT_SECRET chưa được cấu hình.'
      );
    }

    const decoded =
      jwt.verify(
        token,
        process.env.JWT_SECRET
      );

    const user =
      await User.findById(
        decoded.userId
      );

    if (!user) {
      return res.status(401).json({
        success: false,

        message:
          'Người dùng không tồn tại.',
      });
    }

    if (
      user.status !== 'active'
    ) {
      return res.status(403).json({
        success: false,

        message:
          'Tài khoản đã bị khóa.',
      });
    }

    // Lưu user vào request
    req.user = user;

    next();
  } catch (error) {
    if (
      error.name ===
        'JsonWebTokenError' ||
      error.name ===
        'TokenExpiredError'
    ) {
      return res.status(401).json({
        success: false,

        message:
          'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.',
      });
    }

    console.error(
      'Auth middleware error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Không thể xác thực người dùng.',
    });
  }
}

module.exports =
  authMiddleware;
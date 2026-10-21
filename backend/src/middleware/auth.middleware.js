const jwt = require('jsonwebtoken');
const firebase = require('../config/firebase');

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

    if (token.startsWith('firebase:')) {
      if (!firebase.configured()) {
        return res.status(503).json({ success: false, message: 'Dịch vụ xác thực chưa được cấu hình.' });
      }
      const claims = await firebase.verify(token.slice(9));
      const user = await User.findOne({ firebaseUid: claims.uid });
      if (!user) return res.status(401).json({ success: false, message: 'Hãy đăng nhập lại.' });
      if (user.status !== 'active') {
        return res.status(403).json({ success: false, message: 'Tài khoản đã bị khóa.' });
      }
      req.user = user;
      req.firebaseClaims = claims;
      return next();
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

    // Tokens issued before versioning remain valid until the first password change.
    if ((decoded.tokenVersion ?? 0) !== (user.tokenVersion ?? 0)) {
      return res.status(401).json({
        success: false,
        message: 'Mật khẩu đã thay đổi. Vui lòng đăng nhập lại.',
      });
    }

    // Lưu user vào request
    req.user = user;

    next();
  } catch (error) {
    if (error.code?.startsWith('auth/')) {
      return res.status(401).json({ success: false, message: 'Phiên đăng nhập đã hết hạn, bị thu hồi hoặc email chưa xác nhận.' });
    }
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

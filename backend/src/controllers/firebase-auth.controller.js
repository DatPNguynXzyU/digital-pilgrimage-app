const firebase = require('../config/firebase');
const User = require('../models/user.model');

async function signIn(req, res) {
  if (!firebase.configured()) {
    return res.status(503).json({ success: false, message: 'Đăng nhập Google chưa được cấu hình.' });
  }
  const token = req.body?.idToken;
  if (typeof token !== 'string' || token.length > 20000) {
    return res.status(400).json({ success: false, message: 'Thiếu token xác thực.' });
  }
  try {
    const claims = await firebase.verify(token);
    let user = await User.findOne({ firebaseUid: claims.uid });
    if (!user) {
      // Never silently attach a Google identity to an existing local account.
      // It could grant access to that account's private history.
      const email = claims.email.trim().toLowerCase();
      if (await User.exists({ email })) {
        return res.status(409).json({
          success: false,
          message: 'Email này thuộc tài khoản có sẵn. Hãy đăng nhập bằng mật khẩu cũ; chưa hỗ trợ tự động gộp tài khoản.',
        });
      }
      user = await User.create({
        firebaseUid: claims.uid,
        email,
        fullName: (claims.name || email.split('@')[0]).trim().length >= 2
          ? (claims.name || email.split('@')[0]).trim().slice(0, 100)
          : 'Người dùng',
        role: 'user',
        status: 'active',
      });
    }
    if (user.status !== 'active') {
      return res.status(403).json({ success: false, message: 'Tài khoản đã bị khóa.' });
    }
    return res.json({ success: true, token: `firebase:${token}` });
  } catch (error) {
    if (error.code === 11000) {
      // A simultaneous first sign-in may have created the same uid.
      return res.status(409).json({ success: false, message: 'Tài khoản vừa được cập nhật. Vui lòng thử đăng nhập lại.' });
    }
    if (error.code?.startsWith('auth/')) {
      return res.status(error.code === 'auth/email-not-verified' ? 403 : 401).json({
        success: false,
        message: error.code === 'auth/email-not-verified'
          ? 'Hãy mở email xác nhận rồi đăng nhập lại.'
          : 'Xác thực không hợp lệ hoặc đã hết hạn. Hãy đăng nhập lại.',
      });
    }
    return res.status(503).json({ success: false, message: 'Dịch vụ xác thực chưa sẵn sàng.' });
  }
}

async function changePassword(req, res) {
  const password = req.body?.newPassword;
  if (!req.firebaseClaims || typeof password !== 'string' ||
      password.length < 6 || password.length > 128) {
    return res.status(400).json({ success: false, message: 'Mật khẩu phải có từ 6 đến 128 ký tự.' });
  }
  if (req.firebaseClaims.firebase?.sign_in_provider !== 'password' ||
      !Number.isFinite(req.firebaseClaims.auth_time) ||
      Date.now() / 1000 - req.firebaseClaims.auth_time > 300) {
    return res.status(403).json({ success: false, message: 'Hãy xác thực lại bằng mật khẩu trước khi đổi.' });
  }
  try {
    await firebase.auth().updateUser(req.user.firebaseUid, { password });
    await firebase.auth().revokeRefreshTokens(req.user.firebaseUid);
    return res.json({ success: true, message: 'Đã đổi mật khẩu. Vui lòng đăng nhập lại.' });
  } catch (_) {
    return res.status(503).json({ success: false, message: 'Không thể hoàn tất đổi mật khẩu. Hãy đăng nhập lại trước khi thử tiếp.' });
  }
}

module.exports = { signIn, changePassword };

const User = require('../models/user.model');

async function validateRegister(req, res, next) {
  try {
    const { fullName, email, password } = req.body || {};

    // Kiểm tra kiểu dữ liệu
    if (
      typeof fullName !== 'string' ||
      typeof email !== 'string' ||
      typeof password !== 'string'
    ) {
      return res.status(400).json({
        success: false,
        message: 'Thông tin đăng ký không hợp lệ.',
      });
    }

    const normalizedName = fullName.trim();
    const normalizedEmail = email.trim().toLowerCase();

    // Kiểm tra họ tên
    if (
      normalizedName.length < 2 ||
      normalizedName.length > 100
    ) {
      return res.status(400).json({
        success: false,
        message: 'Họ tên phải có từ 2 đến 100 ký tự.',
      });
    }

    // Kiểm tra email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (
      normalizedEmail.length > 254 ||
      !emailRegex.test(normalizedEmail)
    ) {
      return res.status(400).json({
        success: false,
        message: 'Địa chỉ email không hợp lệ.',
      });
    }

    // Kiểm tra mật khẩu
    if (password.length < 6 || password.length > 128) {
      return res.status(400).json({
        success: false,
        message: 'Mật khẩu phải có từ 6 đến 128 ký tự.',
      });
    }

    // Kiểm tra email đã tồn tại
    const existingUser = await User.exists({
      email: normalizedEmail,
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Email này đã được sử dụng.',
      });
    }

    // Chuẩn hóa trước khi chuyển vào controller
    req.body.fullName = normalizedName;
    req.body.email = normalizedEmail;

    next();
  } catch (error) {
    console.error('Validate register error:', error);

    return res.status(500).json({
      success: false,
      message: 'Không thể kiểm tra thông tin đăng ký.',
    });
  }
}

module.exports = validateRegister;
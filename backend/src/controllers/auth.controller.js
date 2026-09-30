const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const User = require('../models/user.model');

// ========================================
// TẠO JWT TOKEN
// ========================================

function createToken(user) {
  if (!process.env.JWT_SECRET) {
    throw new Error(
      'JWT_SECRET chưa được cấu hình.'
    );
  }

  return jwt.sign(
    {
      userId: user._id.toString(),
      role: user.role,
    },
    process.env.JWT_SECRET,
    {
      expiresIn:
        process.env.JWT_EXPIRES_IN || '7d',
    }
  );
}

// ========================================
// LOẠI BỎ DỮ LIỆU KHÔNG CẦN TRẢ VỀ
// ========================================

function sanitizeUser(user) {
  return {
    id: user._id,

    fullName:
      user.fullName,

    email:
      user.email,

    avatar:
      user.avatar,

    role:
      user.role,

    status:
      user.status,

    createdAt:
      user.createdAt,

    updatedAt:
      user.updatedAt,
  };
}

// ========================================
// REGISTER
// ========================================

async function register(req, res) {
  try {
    const {
      fullName,
      email,
      password,
    } = req.body;

    // Kiểm tra dữ liệu bắt buộc
    if (
      !fullName ||
      !email ||
      !password
    ) {
      return res.status(400).json({
        success: false,

        message:
          'Vui lòng nhập đầy đủ họ tên, email và mật khẩu.',
      });
    }

    const normalizedEmail =
      email
        .trim()
        .toLowerCase();

    const emailRegex =
      /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (
      !emailRegex.test(
        normalizedEmail
      )
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Email không hợp lệ.',
      });
    }

    // Tạm thời dùng tối thiểu 6 ký tự.
    if (password.length < 6) {
      return res.status(400).json({
        success: false,

        message:
          'Mật khẩu phải có ít nhất 6 ký tự.',
      });
    }

    // Kiểm tra email tồn tại
    const existingUser =
      await User.findOne({
        email: normalizedEmail,
      });

    if (existingUser) {
      return res.status(409).json({
        success: false,

        message:
          'Email này đã được sử dụng.',
      });
    }

    // Hash password
    const passwordHash =
      await bcrypt.hash(
        password,
        12
      );

    // Tạo user
    const user =
      await User.create({
        fullName:
          fullName.trim(),

        email:
          normalizedEmail,

        passwordHash,

        // Không cho frontend tự chọn admin
        role: 'user',

        status: 'active',
      });

    const token =
      createToken(user);

    return res.status(201).json({
      success: true,

      message:
        'Đăng ký tài khoản thành công.',

      token,

      user:
        sanitizeUser(user),
    });
  } catch (error) {
    console.error(
      'Register error:',
      error
    );

    // Unique email
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,

        message:
          'Email này đã được sử dụng.',
      });
    }

    return res.status(500).json({
      success: false,

      message:
        'Không thể đăng ký tài khoản.',
    });
  }
}

// ========================================
// LOGIN
// ========================================

async function login(req, res) {
  try {
    const {
      email,
      password,
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,

        message:
          'Vui lòng nhập email và mật khẩu.',
      });
    }

    const normalizedEmail =
      email
        .trim()
        .toLowerCase();

    // passwordHash có select:false
    // nên login phải select lại thủ công.
    const user =
      await User.findOne({
        email: normalizedEmail,
      }).select('+passwordHash');

    if (!user) {
      return res.status(401).json({
        success: false,

        message:
          'Email hoặc mật khẩu không đúng.',
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

    const passwordMatched =
      await bcrypt.compare(
        password,
        user.passwordHash
      );

    if (!passwordMatched) {
      return res.status(401).json({
        success: false,

        message:
          'Email hoặc mật khẩu không đúng.',
      });
    }

    const token =
      createToken(user);

    return res.json({
      success: true,

      message:
        'Đăng nhập thành công.',

      token,

      user:
        sanitizeUser(user),
    });
  } catch (error) {
    console.error(
      'Login error:',
      error
    );

    return res.status(500).json({
      success: false,

      message:
        'Không thể đăng nhập.',
    });
  }
}

// ========================================
// GET CURRENT USER
// ========================================

async function getMe(req, res) {
  return res.json({
    success: true,

    user:
      sanitizeUser(req.user),
  });
}

module.exports = {
  register,
  login,
  getMe,
};
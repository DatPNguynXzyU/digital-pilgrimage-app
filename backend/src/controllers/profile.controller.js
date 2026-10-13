const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');

const User = require('../models/user.model');

// =====================================
// THƯ MỤC LƯU ẢNH
// =====================================
const avatarDirectory = path.join(
  __dirname,
  '../../img/avatars'
);

fs.mkdirSync(avatarDirectory, {
  recursive: true,
});

// =====================================
// CẤU HÌNH UPLOAD
// =====================================
const allowedTypes = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, avatarDirectory);
  },

  filename(req, file, cb) {
    const extension = allowedTypes[file.mimetype];

    cb(
      null,
      `${crypto.randomUUID()}${extension}`
    );
  },
});

const upload = multer({
  storage,

  limits: {
    fileSize: 2 * 1024 * 1024,
  },

  fileFilter(req, file, cb) {
    if (!allowedTypes[file.mimetype]) {
      return cb(
        new Error(
          'Chỉ hỗ trợ ảnh JPG, PNG hoặc WEBP.'
        )
      );
    }

    cb(null, true);
  },
});

// Chuyển lỗi Multer thành JSON
function uploadAvatarMiddleware(req, res, next) {
  upload.single('avatar')(
    req,
    res,
    (error) => {
      if (error) {
        return res.status(400).json({
          success: false,
          message:
            error.code === 'LIMIT_FILE_SIZE'
              ? 'Ảnh không được vượt quá 2MB.'
              : error.message,
        });
      }

      next();
    }
  );
}

// =====================================
// PUT /api/auth/profile
// =====================================
async function updateProfile(req, res) {
  try {
    const { fullName } = req.body || {};

    if (typeof fullName !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Họ tên không hợp lệ.',
      });
    }

    const normalizedName = fullName.trim();

    if (
      normalizedName.length < 2 ||
      normalizedName.length > 100
    ) {
      return res.status(400).json({
        success: false,
        message:
          'Họ tên phải có từ 2 đến 100 ký tự.',
      });
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        $set: {
          fullName: normalizedName,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    ).select('fullName email avatar role');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy tài khoản.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Cập nhật hồ sơ thành công.',
      data: user,
    });
  } catch (error) {
    console.error('Update profile error:', error);

    return res.status(500).json({
      success: false,
      message: 'Không thể cập nhật hồ sơ.',
    });
  }
}

// =====================================
// POST /api/auth/avatar
// =====================================
async function updateAvatar(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chọn ảnh đại diện.',
      });
    }

    const avatarPath =
      `/img/avatars/${req.file.filename}`;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        $set: {
          avatar: avatarPath,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    ).select('fullName email avatar role');

    if (!user) {
      fs.unlink(req.file.path, () => {});

      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy tài khoản.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Cập nhật ảnh đại diện thành công.',
      data: user,
    });
  } catch (error) {
    console.error('Update avatar error:', error);

    return res.status(500).json({
      success: false,
      message: 'Không thể cập nhật ảnh đại diện.',
    });
  }
}

module.exports = {
  updateProfile,
  updateAvatar,
  uploadAvatarMiddleware,
};
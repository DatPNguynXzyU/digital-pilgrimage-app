const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 100,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
      maxlength: 150,
      match: [
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        'Email không hợp lệ.',
      ],
    },

    passwordHash: {
      type: String,
      required: true,

      // Khi query User bình thường,
      // passwordHash sẽ không được trả về.
      select: false,
    },

    avatar: {
      type: String,
      default: '',
    },

    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },

    status: {
      type: String,
      enum: ['active', 'blocked'],
      default: 'active',
    },
  },
  {
    timestamps: true,
  }
);

userSchema.index({
  status: 1,
});

module.exports = mongoose.model(
  'User',
  userSchema
);
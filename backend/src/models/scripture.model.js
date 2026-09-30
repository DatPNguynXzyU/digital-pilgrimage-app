const mongoose = require('mongoose');

const scriptureSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 250,
    },

    slug: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
    },

    // Tạm thời giữ Kinh / Chú để không làm hỏng Flutter hiện tại
    type: {
      type: String,
      required: true,
      enum: ['Kinh', 'Chú'],
    },

    description: {
      type: String,
      default: '',
    },

    content: {
      type: String,
      required: true,
    },

    source: {
      type: String,
      default: '',
    },

    imageUrl: {
      type: String,
      default: '',
    },

    order: {
      type: Number,
      default: 0,
      min: 0,
    },

    isFeatured: {
      type: Boolean,
      default: false,
    },

    status: {
      type: String,
      enum: ['active', 'inactive'],
      default: 'active',
    },
  },
  {
    timestamps: true,
  }
);

// slug không được trùng
scriptureSchema.index(
  {
    slug: 1,
  },
  {
    unique: true,
    sparse: true,
  }
);

// tìm kiếm
scriptureSchema.index({
  title: 'text',
  description: 'text',
});

scriptureSchema.index({
  type: 1,
  order: 1,
});

module.exports = mongoose.model(
  'Scripture',
  scriptureSchema
);
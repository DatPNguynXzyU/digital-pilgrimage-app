const mongoose = require('mongoose');

const quoteSchema = new mongoose.Schema(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },

    content: {
      type: String,
      required: true,
      trim: true,
      maxlength: 2000,
    },

    author: {
      type: String,
      default: '',
      trim: true,
    },

    source: {
      type: String,
      default: '',
      trim: true,
    },

    category: {
      type: String,
      enum: [
        'wisdom',
        'compassion',
        'mindfulness',
        'peace',
        'practice',
        'other',
      ],
      default: 'other',
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

quoteSchema.index({
  category: 1,
  isActive: 1,
});

module.exports = mongoose.model(
  'Quote',
  quoteSchema
);
const mongoose = require('mongoose');

const scriptureSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },

    slug: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

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
    },

    featured: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  'Scripture',
  scriptureSchema
);
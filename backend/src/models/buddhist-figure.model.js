const mongoose = require('mongoose');

const buddhistFigureSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    slug: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    sanskritName: {
      type: String,
      default: '',
    },

    otherNames: {
      type: [String],
      default: [],
    },

    category: {
      type: String,
      required: true,
      enum: [
        'buddha',
        'bodhisattva',
        'arhat',
        'patriarch',
        'guardian',
        'other',
      ],
    },

    description: {
      type: String,
      default: '',
    },

    biography: {
      type: String,
      default: '',
    },

    symbolism: {
      type: String,
      default: '',
    },

    appearance: {
      type: String,
      default: '',
    },

    thumbnail: {
      type: String,
      default: '',
    },

    images: {
      type: [String],
      default: [],
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

buddhistFigureSchema.index({
  name: 'text',
  otherNames: 'text',
});

module.exports = mongoose.model(
  'BuddhistFigure',
  buddhistFigureSchema
);
const mongoose = require('mongoose');

const templeSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },

    slug: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    otherNames: {
      type: [String],
      default: [],
    },

    description: {
      type: String,
      default: '',
    },

    history: {
      type: String,
      default: '',
    },

    address: {
      street: {
        type: String,
        default: '',
      },

      ward: {
        type: String,
        default: '',
      },

      city: {
        type: String,
        default: '',
      },

      country: {
        type: String,
        default: 'Việt Nam',
      },
    },

    location: {
      latitude: {
        type: Number,
        min: -90,
        max: 90,
      },

      longitude: {
        type: Number,
        min: -180,
        max: 180,
      },
    },

    thumbnail: {
      type: String,
      default: '',
    },

    images: {
      type: [String],
      default: [],
    },

    foundedYear: {
      type: Number,
      min: 0,
    },

    tradition: {
      type: String,
      default: '',
    },

    openingHours: {
      open: {
        type: String,
        default: '',
      },

      close: {
        type: String,
        default: '',
      },
    },

    contact: {
      phone: {
        type: String,
        default: '',
      },

      website: {
        type: String,
        default: '',
      },

      email: {
        type: String,
        default: '',
      },
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

templeSchema.index({
  name: 'text',
  description: 'text',
});

templeSchema.index({
  'address.city': 1,
});

module.exports = mongoose.model('Temple', templeSchema);
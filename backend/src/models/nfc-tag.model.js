const mongoose = require('mongoose');

const nfcTagSchema = new mongoose.Schema(
  {
    uid: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      uppercase: true,
    },

    templeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Temple',
      required: true,
      index: true,
    },

    label: {
      type: String,
      trim: true,
      default: '',
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

nfcTagSchema.index({
  templeId: 1,
  status: 1,
});

module.exports = mongoose.model(
  'NfcTag',
  nfcTagSchema
);
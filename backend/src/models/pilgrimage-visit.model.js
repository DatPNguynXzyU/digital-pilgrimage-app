const mongoose = require('mongoose');

const pilgrimageVisitSchema =
  new mongoose.Schema(
    {
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true,
      },

      templeId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Temple',
        required: true,
        index: true,
      },

      nfcTagId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'NfcTag',
        required: true,
      },

      visitDate: {
        type: Date,
        default: Date.now,
        index: true,
      },

      note: {
        type: String,
        trim: true,
        maxlength: 500,
        default: '',
      },
    },
    {
      timestamps: true,
    }
  );

pilgrimageVisitSchema.index({
  userId: 1,
  visitDate: -1,
});

pilgrimageVisitSchema.index({
  userId: 1,
  templeId: 1,
});

pilgrimageVisitSchema.index({ templeId: 1, visitDate: 1, userId: 1 });

module.exports = mongoose.model(
  'PilgrimageVisit',
  pilgrimageVisitSchema
);

const mongoose = require('mongoose');

const templeStampSchema =
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

      firstVisitId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'PilgrimageVisit',
        required: true,
      },

      receivedAt: {
        type: Date,
        default: Date.now,
      },
    },
    {
      timestamps: true,
    }
  );

templeStampSchema.index(
  {
    userId: 1,
    templeId: 1,
  },
  {
    unique: true,
  }
);

module.exports = mongoose.model(
  'TempleStamp',
  templeStampSchema
);
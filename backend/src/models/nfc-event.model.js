const mongoose = require('mongoose');

// Reporting windows, distinct from users' private calendar entries.
const schema = new mongoose.Schema({
  title: { type: String, required: true, trim: true, maxlength: 200 },
  templeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Temple', required: true },
  startAt: { type: Date, required: true },
  endAt: { type: Date, required: true },
}, { timestamps: true });
schema.index({ templeId: 1, startAt: 1, endAt: 1 });
module.exports = mongoose.model('NfcEvent', schema);

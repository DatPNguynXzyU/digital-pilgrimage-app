const mongoose = require('mongoose');
const { randomUUID } = require('crypto');
// Keep Flutter local wall-clock strings for lunar and recurring events.
const schema = new mongoose.Schema({
  _id: { type: String, default: randomUUID },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true, trim: true, maxlength: 200 },
  startAt: { type: String, required: true },
  endAt: { type: String, required: true },
  usesLunarDate: { type: Boolean, default: false },
  location: { type: String, default: '', maxlength: 500 },
  description: { type: String, default: '', maxlength: 5000 },
  reminderMinutes: { type: Number, default: null, min: 0, max: 525600 },
  repeat: { type: String, enum: ['none', 'daily', 'weekly', 'monthly', 'yearly'], default: 'none' },
}, { timestamps: true });
schema.index({ userId: 1, startAt: 1 });
module.exports = mongoose.model('CalendarEvent', schema);

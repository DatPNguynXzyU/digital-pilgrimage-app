const CalendarEvent = require('../models/calendar-event.model');
const fields = ['title', 'startAt', 'endAt', 'usesLunarDate', 'location', 'description', 'reminderMinutes', 'repeat'];
const validId = value => typeof value === 'string' && /^[a-zA-Z0-9_-]{1,100}$/.test(value);
function validDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})?$/.test(value)) return false;
  const day = value.slice(0, 10);
  const parsed = new Date(day + 'T00:00:00Z');
  return Number.isFinite(Date.parse(value)) && Number.isFinite(parsed.getTime()) &&
    parsed.toISOString().slice(0, 10) === day &&
    Number(value.slice(11,13)) < 24 && Number(value.slice(14,16)) < 60 && Number(value.slice(17,19)) < 60;
}
function validate(data) {
  return typeof data.title === 'string' && data.title.trim().length > 0 && data.title.trim().length <= 200 &&
    validDate(data.startAt) && validDate(data.endAt) && Date.parse(data.endAt) >= Date.parse(data.startAt) &&
    (data.usesLunarDate === undefined || typeof data.usesLunarDate === 'boolean') &&
    (data.location === undefined || (typeof data.location === 'string' && data.location.length <= 500)) &&
    (data.description === undefined || (typeof data.description === 'string' && data.description.length <= 5000)) &&
    (data.reminderMinutes == null || (Number.isInteger(data.reminderMinutes) && data.reminderMinutes >= 0 && data.reminderMinutes <= 525600)) &&
    (data.repeat === undefined || ['none', 'daily', 'weekly', 'monthly', 'yearly'].includes(data.repeat));
}
function payload(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) return null;
  if (Object.keys(body).some(key => !fields.includes(key) && key !== 'id')) return null;
  return Object.fromEntries(fields.filter(key => Object.hasOwn(body, key)).map(key => [key, body[key]]));
}
function serialize(event) {
  const value = event.toObject();
  return { id: value._id, ...Object.fromEntries(fields.map(key => [key, value[key]])) };
}
const invalid = res => res.status(400).json({ success: false, message: 'Dữ liệu lịch không hợp lệ.' });
const missing = res => res.status(404).json({ success: false, message: 'Không tìm thấy lịch.' });
function failure(res, error) {
  if (error.code === 11000) return res.status(409).json({ success: false, message: 'ID lịch đã tồn tại.' });
  if (error.name === 'ValidationError') return invalid(res);
  console.error('Calendar error:', error);
  return res.status(500).json({ success: false, message: 'Không thể xử lý lịch cá nhân.' });
}
async function getCalendarEvents(req, res) {
  try {
    const events = await CalendarEvent.find({ userId: req.user._id }).sort({ startAt: 1, _id: 1 });
    return res.json({ success: true, count: events.length, data: events.map(serialize) });
  } catch (error) { return failure(res, error); }
}
async function getCalendarEventById(req, res) {
  if (!validId(req.params.id)) return invalid(res);
  try {
    const event = await CalendarEvent.findOne({ _id: req.params.id, userId: req.user._id });
    return event ? res.json({ success: true, data: serialize(event) }) : missing(res);
  } catch (error) { return failure(res, error); }
}
async function createCalendarEvent(req, res) {
  const data = payload(req.body);
  if (!data || !validate(data) || (req.body.id !== undefined && !validId(req.body.id))) return invalid(res);
  try {
    const event = await CalendarEvent.create({ ...data, _id: req.body.id, userId: req.user._id });
    return res.status(201).json({ success: true, data: serialize(event) });
  } catch (error) { return failure(res, error); }
}
async function updateCalendarEvent(req, res) {
  const data = payload(req.body);
  if (!validId(req.params.id) || !data || !Object.keys(data).length ||
      (req.body.id !== undefined && req.body.id !== req.params.id)) return invalid(res);
  try {
    const event = await CalendarEvent.findOne({ _id: req.params.id, userId: req.user._id });
    if (!event) return missing(res);
    if (!validate({ ...event.toObject(), ...data })) return invalid(res);
    const updated = await CalendarEvent.findOneAndUpdate(
      { _id: event._id, userId: req.user._id, __v: event.__v },
      { $set: data, $inc: { __v: 1 } }, { new: true, runValidators: true }
    );
    if (!updated) return res.status(409).json({ success: false, message: 'Lịch đã thay đổi. Vui lòng tải lại.' });
    return res.json({ success: true, data: serialize(updated) });
  } catch (error) { return failure(res, error); }
}
async function deleteCalendarEvent(req, res) {
  if (!validId(req.params.id)) return invalid(res);
  try {
    const event = await CalendarEvent.findOneAndDelete({ _id: req.params.id, userId: req.user._id });
    return event ? res.json({ success: true, data: serialize(event) }) : missing(res);
  } catch (error) { return failure(res, error); }
}
module.exports = { getCalendarEvents, getCalendarEventById, createCalendarEvent, updateCalendarEvent, deleteCalendarEvent };

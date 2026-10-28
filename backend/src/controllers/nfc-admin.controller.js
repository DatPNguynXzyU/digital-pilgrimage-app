const mongoose = require('mongoose');
const Visit = require('../models/pilgrimage-visit.model');
const Temple = require('../models/temple.model');
const Event = require('../models/nfc-event.model');
const DAY = 86400000;
const ZONE = 'Asia/Ho_Chi_Minh';
const id = value => typeof value === 'string' && /^[a-f\d]{24}$/i.test(value);
function day(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  const date = new Date(value + 'T00:00:00Z');
  return Number.isFinite(+date) && date.toISOString().slice(0, 10) === value ? date : null;
}
function range(query, now = new Date()) {
  const today = new Date(+now + 7 * 3600000).toISOString().slice(0, 10);
  const to = query.to === undefined ? day(today) : day(query.to);
  const from = query.from === undefined && to ? new Date(+to - 29 * DAY) : day(query.from);
  if (!from || !to || to < from || (+to - from) / DAY >= 366 ||
      (query.templeId !== undefined && !id(query.templeId))) throw new Error('Chọn ngày hợp lệ (YYYY-MM-DD), tối đa 366 ngày và chùa hợp lệ.');
  return { from: from.toISOString().slice(0, 10), to: to.toISOString().slice(0, 10),
    start: new Date(+from - 7 * 3600000), end: new Date(+to + DAY - 7 * 3600000) };
}
// First group by user to count distinct participants without unbounded arrays.
function counts(key) {
  return [
    { $group: { _id: { bucket: key, user: '$userId' }, scans: { $sum: 1 } } },
    { $group: { _id: '$_id.bucket', scans: { $sum: '$scans' }, participants: { $sum: 1 } } },
  ];
}
async function statistics(req, res) {
  let period;
  try { period = range(req.query); } catch (error) {
    return res.status(400).json({ success: false, message: error.message });
  }
  try {
    const templeFilter = req.query.templeId ? { templeId: new mongoose.Types.ObjectId(req.query.templeId) } : {};
    const [summary, events] = await Promise.all([
      Visit.aggregate([
        { $match: { ...templeFilter, visitDate: { $gte: period.start, $lt: period.end } } },
        { $facet: {
          total: counts(null),
          days: [...counts({ $dateToString: { date: '$visitDate', format: '%Y-%m-%d', timezone: ZONE } }), { $sort: { _id: 1 } }],
          temples: [...counts('$templeId'),
            { $lookup: { from: Temple.collection.name, localField: '_id', foreignField: '_id', as: 'temple' } },
            { $project: { scans: 1, participants: 1, name: { $ifNull: [{ $arrayElemAt: ['$temple.name', 0] }, 'Chùa đã xóa'] } } },
            { $sort: { scans: -1, _id: 1 } }],
        } },
      ]).option({ maxTimeMS: 15000 }),
      Event.aggregate([
        { $match: { ...templeFilter, startAt: { $lt: period.end }, endAt: { $gt: period.start } } },
        { $sort: { startAt: -1, _id: 1 } },
        { $limit: 101 },
        { $lookup: { from: Visit.collection.name,
          let: { temple: '$templeId', start: { $max: ['$startAt', period.start] }, end: { $min: ['$endAt', period.end] } },
          pipeline: [{ $match: { $expr: { $and: [
            { $eq: ['$templeId', '$$temple'] }, { $gte: ['$visitDate', '$$start'] }, { $lt: ['$visitDate', '$$end'] },
          ] } } }, ...counts(null)], as: 'totals' } },
        { $lookup: { from: Temple.collection.name, localField: 'templeId', foreignField: '_id', as: 'temple' } },
        { $project: { title: 1, templeId: 1, startAt: 1, endAt: 1,
          templeName: { $ifNull: [{ $arrayElemAt: ['$temple.name', 0] }, 'Chùa đã xóa'] },
          scans: { $ifNull: [{ $arrayElemAt: ['$totals.scans', 0] }, 0] },
          participants: { $ifNull: [{ $arrayElemAt: ['$totals.participants', 0] }, 0] },
        } },
      ]).option({ maxTimeMS: 15000 }),
    ]);
    const result = summary[0];
    const days = [];
    const byDay = new Map(result.days.map(value => [value._id, value]));
    for (let date = day(period.from); date <= day(period.to); date = new Date(+date + DAY)) {
      const key = date.toISOString().slice(0, 10);
      days.push(byDay.get(key) || { _id: key, scans: 0, participants: 0 });
    }
    return res.json({ success: true, data: {
      from: period.from, to: period.to, timezone: ZONE,
      total: result.total[0] || { scans: 0, participants: 0 },
      activeTemples: result.temples.length, days, temples: result.temples,
      events: events.slice(0, 100), eventsTruncated: events.length > 100,
    } });
  } catch (error) {
    console.error('NFC statistics:', error);
    return res.status(500).json({ success: false, message: 'Không thể tải thống kê. Thử thu hẹp khoảng ngày.' });
  }
}
async function temples(req, res) {
  try { res.json({ success: true, data: await Temple.find().select('name slug status').sort({ name: 1 }).lean() }); }
  catch { res.status(500).json({ success: false, message: 'Không thể tải danh sách chùa.' }); }
}
async function createEvent(req, res) {
  const { title, templeId, startAt, endAt } = req.body || {};
  const timestamp = value => typeof value === 'string' &&
    /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,3})?(Z|[+-]\d{2}:\d{2})$/.test(value) &&
    day(value.slice(0, 10)) && Number(value.slice(11, 13)) < 24 && Number.isFinite(Date.parse(value));
  if (typeof title !== 'string' || !title.trim() || title.trim().length > 200 || !id(templeId) ||
      !timestamp(startAt) || !timestamp(endAt) || Date.parse(endAt) <= Date.parse(startAt) ||
      Date.parse(endAt) - Date.parse(startAt) > 366 * DAY) {
    return res.status(400).json({ success: false, message: 'Tên, chùa và thời gian sự kiện không hợp lệ (tối đa 366 ngày).' });
  }
  try {
    if (!await Temple.exists({ _id: templeId })) return res.status(404).json({ success: false, message: 'Không tìm thấy chùa.' });
    const data = await Event.create({ title: title.trim(), templeId, startAt, endAt });
    return res.status(201).json({ success: true, data });
  } catch { return res.status(500).json({ success: false, message: 'Không thể lưu sự kiện.' }); }
}
module.exports = { statistics, temples, createEvent, range };

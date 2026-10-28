const Tag = require('../models/nfc-tag.model');
const Temple = require('../models/temple.model');

function uidOf(value) {
  if (typeof value !== 'string' || !/^[a-f\d:\s-]+$/i.test(value)) return null;
  const uid = value.replace(/[:\s-]/g, '').toUpperCase();
  return /^(?:[A-F\d]{2}){4,10}$/.test(uid) ? uid : null;
}
const validId = value => typeof value === 'string' && /^[a-f\d]{24}$/i.test(value);
const invalid = res => res.status(400).json({ success: false, message: 'UID, chùa hoặc trạng thái thẻ không hợp lệ.' });
function fail(res, error) {
  if (error.code === 11000) return res.status(409).json({ success: false, message: 'Thẻ vừa được đăng ký. Hãy đọc lại để kiểm tra liên kết.' });
  console.error('Admin NFC tag:', error);
  return res.status(500).json({ success: false, message: 'Không thể cập nhật thẻ NFC.' });
}
async function inspect(req, res) {
  const uid = uidOf(req.params.uid);
  if (!uid) return invalid(res);
  try {
    const tag = await Tag.findOne({ uid }).populate('templeId', 'name slug status').lean();
    return res.json({ success: true, data: { uid, tag } });
  } catch (error) { return fail(res, error); }
}
async function register(req, res) {
  const { uid: raw, templeId } = req.body || {};
  const uid = uidOf(raw);
  if (!uid || !validId(templeId)) return invalid(res);
  try {
    const temple = await Temple.findOne({ _id: templeId, status: 'active' }).lean();
    if (!temple) return res.status(404).json({ success: false, message: 'Chùa không tồn tại hoặc đã ngừng hoạt động.' });
    const existing = await Tag.findOne({ uid });
    if (existing) {
      if (existing.templeId.toString() !== templeId.toLowerCase()) return res.status(409).json({ success: false, message: 'UID đã thuộc chùa khác. Không thể gán lại bằng thao tác ghi thẻ.' });
      if (existing.status !== 'active') return res.status(409).json({ success: false, message: 'Thẻ đang bị vô hiệu hóa. Hãy bật lại thẻ trước.' });
      return res.json({ success: true, data: existing });
    }
    const tag = await Tag.create({ uid, templeId, label: `Thẻ ${temple.name}`, status: 'active' });
    return res.status(201).json({ success: true, data: tag });
  } catch (error) { return fail(res, error); }
}
async function status(req, res) {
  const uid = uidOf(req.params.uid);
  const status = req.body?.status;
  if (!uid || !['active', 'inactive'].includes(status)) return invalid(res);
  try {
    const tag = await Tag.findOneAndUpdate({ uid }, { $set: { status } }, { new: true, runValidators: true });
    if (!tag) return res.status(404).json({ success: false, message: 'Thẻ chưa đăng ký trên máy chủ.' });
    return res.json({ success: true, data: tag });
  } catch (error) { return fail(res, error); }
}
module.exports = { uidOf, inspect, register, status };

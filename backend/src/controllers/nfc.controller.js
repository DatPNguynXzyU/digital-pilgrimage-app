const mongoose = require('mongoose');

const NfcTag = require('../models/nfc-tag.model');
const Temple = require('../models/temple.model');
const PilgrimageVisit = require('../models/pilgrimage-visit.model');
const TempleStamp = require('../models/temple-stamp.model');

// ======================================================
// CHUẨN HÓA UID NFC
// Ví dụ: 04:A1:B2:C3 -> 04A1B2C3
// ======================================================
function normalizeUid(uid) {
  if (!uid || typeof uid !== 'string') {
    return '';
  }

  return uid.replace(/[^0-9a-fA-F]/g, '').toUpperCase();
}

// ======================================================
// CHUẨN HÓA SLUG
// ======================================================
function normalizeSlug(slug) {
  if (!slug || typeof slug !== 'string') {
    return '';
  }

  return slug.trim().toLowerCase();
}

// ======================================================
// GET /api/nfc/temple/:uid
// Tra cứu thông tin chùa qua UID của thẻ NFC (công khai)
// ======================================================
async function getTempleByTagUid(req, res) {
  try {
    const normalizedUid = normalizeUid(req.params.uid);

    if (!normalizedUid) {
      return res.status(400).json({
        success: false,
        message: 'UID NFC không hợp lệ.',
      });
    }

    const nfcTag = await NfcTag.findOne({
      uid: normalizedUid,
      status: 'active',
    })
      .populate('templeId')
      .lean();

    if (!nfcTag || !nfcTag.templeId || nfcTag.templeId.status !== 'active') {
      return res.status(404).json({
        success: false,
        registered: false,
        message: 'Thẻ NFC chưa được liên kết với chùa nào.',
        uid: normalizedUid,
      });
    }

    const temple = nfcTag.templeId;

    return res.status(200).json({
      success: true,
      registered: true,
      data: {
        temple: {
          ...temple,
          id: temple._id,
        },
        nfc: {
          uid: normalizedUid,
          tagId: nfcTag._id,
          label: nfcTag.label || `Thẻ NFC ${temple.name}`,
          slug: temple.slug,
        },
      },
    });
  } catch (error) {
    console.error('Get temple by NFC UID error:', error);
    return res.status(500).json({
      success: false,
      message: 'Lỗi khi tra cứu thẻ NFC.',
    });
  }
}

// ======================================================
// POST /api/nfc/scan
//
// Body:
// {
//   "uid": "04A1B2C3D4E5",
//   "slug": "chua-giac-lam" // Nếu gửi, phải khớp với chùa đã đăng ký
// }
//
// Yêu cầu:
// Authorization: Bearer JWT
// ======================================================
async function scanNfc(req, res) {
  const {
    uid,
    slug,
    templeId,
  } = req.body || {};

  const normalizedUid = normalizeUid(uid);
  const normalizedSlug = normalizeSlug(slug);

  if (!normalizedUid) {
    return res.status(400).json({
      success: false,
      message: 'UID NFC không hợp lệ.',
    });
  }

  const userId = req.user._id;
  const session = await mongoose.startSession();
  let responseData = null;

  try {
    await session.withTransaction(async () => {
      // A scan may use an existing registration, but must never create or reassign it.
      const nfcTag = await NfcTag.findOne({
        uid: normalizedUid,
        status: 'active',
      }).session(session);
      if (!nfcTag) {
        const error = new Error('Thẻ NFC không tồn tại hoặc đã bị vô hiệu hóa.');
        error.statusCode = 404;
        throw error;
      }
      const temple = await Temple.findOne({
        _id: nfcTag.templeId,
        status: 'active',
      }).session(session).lean();
      if (!temple) {
        const error = new Error('Chùa liên kết với thẻ NFC không tồn tại hoặc đã bị vô hiệu hóa.');
        error.statusCode = 404;
        throw error;
      }
      if ((slug !== undefined && normalizedSlug !== normalizeSlug(temple.slug)) ||
          (templeId !== undefined && templeId !== temple._id.toString())) {
        const error = new Error('Thông tin trên thẻ NFC không khớp với chùa đã đăng ký.');
        error.statusCode = 400;
        throw error;
      }

      // 4. TẠO LẦN VIẾNG MỚI (CHECK-IN)
      const visits = await PilgrimageVisit.create(
        [
          {
            userId,
            templeId: temple._id,
            nfcTagId: nfcTag._id,
            visitDate: new Date(),
          },
        ],
        { session }
      );
      const visit = visits[0];

      // 5. KIỂM TRA / CẤP TEM CHÙA CHO NGƯỜI DÙNG
      let stamp = await TempleStamp.findOne({
        userId,
        templeId: temple._id,
      }).session(session);

      let isNewStamp = false;

      if (!stamp) {
        const stamps = await TempleStamp.create(
          [
            {
              userId,
              templeId: temple._id,
              firstVisitId: visit._id,
              receivedAt: new Date(),
            },
          ],
          { session }
        );
        stamp = stamps[0];
        isNewStamp = true;
      }

      // 6. ĐẾM SỐ LẦN USER ĐÃ VIẾNG NGÔI CHÙA NÀY
      const visitCount = await PilgrimageVisit.countDocuments({
        userId,
        templeId: temple._id,
      }).session(session);

      // 7. DỮ LIỆU PHẢN HỒI
      responseData = {
        temple: {
          ...temple,
          id: temple._id,
          _id: temple._id,
        },
        nfc: {
          uid: normalizedUid,
          tagId: nfcTag._id,
          slug: temple.slug,
        },
        visit: {
          id: visit._id,
          visitDate: visit.visitDate,
          visitCount,
        },
        stamp: {
          id: stamp._id,
          receivedAt: stamp.receivedAt,
          isNew: isNewStamp,
        },
      };
    });

    return res.status(200).json({
      success: true,
      message: responseData.stamp.isNew
        ? `Check-in thành công tại ${responseData.temple.name}. Bạn đã nhận được tem mới!`
        : `Check-in thành công tại ${responseData.temple.name}.`,
      data: responseData,
    });
  } catch (error) {
    console.error('NFC scan error:', error);
    return res.status(error.statusCode || 500).json({
      success: false,
      uid: normalizedUid,
      message: error.statusCode ? error.message : 'Không thể xử lý check-in NFC.',
    });
  } finally {
    await session.endSession();
  }
}

// ======================================================
// GET /api/nfc/tags
// ======================================================
async function getAllNfcTags(req, res) {
  try {
    const tags = await NfcTag.find()
      .populate('templeId', 'name slug thumbnail address')
      .sort({ updatedAt: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      total: tags.length,
      data: tags,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Không thể lấy danh sách thẻ NFC.',
    });
  }
}

module.exports = {
  scanNfc,
  getTempleByTagUid,
  getAllNfcTags,
};

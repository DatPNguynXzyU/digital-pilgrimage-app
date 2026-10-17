const mongoose = require('mongoose');

const NfcTag = require('../models/nfc-tag.model');
const Temple = require('../models/temple.model');
const PilgrimageVisit = require(
  '../models/pilgrimage-visit.model'
);
const TempleStamp = require(
  '../models/temple-stamp.model'
);

// ======================================================
// CHUẨN HÓA UID NFC
//
// Ví dụ:
//
// 04:A1:B2:C3
// 04-A1-B2-C3
// 04 a1 b2 c3
//
// đều thành:
//
// 04A1B2C3
// ======================================================
function normalizeUid(uid) {
  if (
    !uid ||
    typeof uid !== 'string'
  ) {
    return '';
  }

  return uid
    .replace(
      /[^0-9a-fA-F]/g,
      ''
    )
    .toUpperCase();
}

// ======================================================
// CHUẨN HÓA SLUG
// ======================================================
function normalizeSlug(slug) {
  if (
    !slug ||
    typeof slug !== 'string'
  ) {
    return '';
  }

  return slug
    .trim()
    .toLowerCase();
}

// ======================================================
// POST /api/nfc/scan
//
// Body:
//
// {
//   "uid": "04A1B2C3D4E5",
//   "slug": "chua-giac-lam"
// }
//
// Yêu cầu:
// Authorization: Bearer JWT
// ======================================================
async function scanNfc(req, res) {
  const {
    uid,
    slug,
  } = req.body || {};

  const normalizedUid =
    normalizeUid(uid);

  const normalizedSlug =
    normalizeSlug(slug);

  // ====================================================
  // VALIDATE UID
  // ====================================================
  if (!normalizedUid) {
    return res.status(400).json({
      success: false,
      message:
        'UID NFC không hợp lệ.',
    });
  }

  // ====================================================
  // VALIDATE SLUG TRONG NDEF
  // ====================================================
  if (!normalizedSlug) {
    return res.status(400).json({
      success: false,
      message:
        'Thẻ NFC không chứa thông tin chùa.',
    });
  }

  // ====================================================
  // USER LẤY TỪ JWT
  //
  // KHÔNG nhận userId từ request body.
  // ====================================================
  const userId =
    req.user._id;

  const session =
    await mongoose.startSession();

  let responseData = null;

  try {
    await session.withTransaction(
      async () => {
        // =================================================
        // 1. TÌM THẺ NFC THEO UID
        // =================================================
        const nfcTag =
          await NfcTag.findOne({
            uid: normalizedUid,
            status: 'active',
          }).session(session);

        if (!nfcTag) {
          const error =
            new Error(
              'Thẻ NFC không tồn tại hoặc đã bị vô hiệu hóa.'
            );

          error.statusCode = 404;

          throw error;
        }

        // =================================================
        // 2. TÌM CHÙA ĐƯỢC GẮN VỚI THẺ NFC
        // =================================================
        const temple =
          await Temple.findOne({
            _id: nfcTag.templeId,
            status: 'active',
          })
            .session(session)
            .lean();

        if (!temple) {
          const error =
            new Error(
              'Chùa liên kết với thẻ NFC không tồn tại hoặc đã bị vô hiệu hóa.'
            );

          error.statusCode = 404;

          throw error;
        }

        // =================================================
        // 3. KIỂM TRA NDEF SLUG
        //
        // Ví dụ:
        //
        // UID MongoDB
        // → Chùa Giác Lâm
        //
        // NDEF:
        // slug = chua-giac-lam
        //
        // Phải khớp nhau.
        // =================================================
        const templeSlug =
          normalizeSlug(
            temple.slug
          );

        if (
          normalizedSlug !==
          templeSlug
        ) {
          const error =
            new Error(
              'Thông tin trên thẻ NFC không khớp với chùa đã đăng ký.'
            );

          error.statusCode = 400;

          throw error;
        }

        // =================================================
        // 4. TẠO LẦN VIẾNG MỚI
        //
        // Mỗi lần scan hợp lệ:
        // pilgrimage_visits + 1
        // =================================================
        const visits =
          await PilgrimageVisit.create(
            [
              {
                userId,

                templeId:
                  temple._id,

                nfcTagId:
                  nfcTag._id,

                visitDate:
                  new Date(),
              },
            ],
            {
              session,
            }
          );

        const visit =
          visits[0];

        // =================================================
        // 5. KIỂM TRA TEM CHÙA
        //
        // Mỗi user chỉ nhận một tem/chùa.
        // =================================================
        let stamp =
          await TempleStamp.findOne({
            userId,

            templeId:
              temple._id,
          }).session(session);

        let isNewStamp = false;

        if (!stamp) {
          const stamps =
            await TempleStamp.create(
              [
                {
                  userId,

                  templeId:
                    temple._id,

                  firstVisitId:
                    visit._id,

                  receivedAt:
                    new Date(),
                },
              ],
              {
                session,
              }
            );

          stamp =
            stamps[0];

          isNewStamp = true;
        }

        // =================================================
        // 6. ĐẾM SỐ LẦN USER ĐÃ VIẾNG CHÙA
        // =================================================
        const visitCount =
          await PilgrimageVisit
            .countDocuments({
              userId,

              templeId:
                temple._id,
            })
            .session(session);

        // =================================================
        // 7. RESPONSE DATA
        // =================================================
        responseData = {
          temple: {
            id:
              temple._id,

            name:
              temple.name,

            slug:
              temple.slug,

            thumbnail:
              temple.thumbnail,

            address:
              temple.address,
          },

          nfc: {
            uid:
              normalizedUid,

            tagId:
              nfcTag._id,
          },

          visit: {
            id:
              visit._id,

            visitDate:
              visit.visitDate,

            visitCount,
          },

          stamp: {
            id:
              stamp._id,

            receivedAt:
              stamp.receivedAt,

            isNew:
              isNewStamp,
          },
        };
      }
    );

    // ====================================================
    // THÀNH CÔNG
    // ====================================================
    return res.status(200).json({
      success: true,

      message:
        responseData.stamp.isNew
          ? 'Check-in thành công. Bạn đã nhận được tem chùa mới.'
          : 'Check-in thành công.',

      data:
        responseData,
    });
  } catch (error) {
    console.error(
      'NFC scan error:',
      error
    );

    return res
      .status(
        error.statusCode ||
          500
      )
      .json({
        success: false,

        message:
          error.statusCode
            ? error.message
            : 'Không thể xử lý check-in NFC.',
      });
  } finally {
    await session.endSession();
  }
}

module.exports = {
  scanNfc,
};

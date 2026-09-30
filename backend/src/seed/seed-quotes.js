const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

const Quote =
  require('../models/quote.model');

const connectDatabase =
  require('../config/database');

dotenv.config({
  path: path.join(__dirname, '../../.env'),
});

// ========================================
// CHUẨN HÓA CATEGORY
// ========================================

function normalizeCategory(category) {
  if (!category) {
    return 'other';
  }

  const value = category
    .trim()
    .toLowerCase();

  const categoryMap = {
    // Trí tuệ
    'trí tuệ': 'wisdom',
    'tri tue': 'wisdom',
    'wisdom': 'wisdom',

    // Từ bi
    'từ bi': 'compassion',
    'tu bi': 'compassion',
    'compassion': 'compassion',

    // Chánh niệm
    'chánh niệm': 'mindfulness',
    'chanh niem': 'mindfulness',
    'mindfulness': 'mindfulness',

    // Bình an
    'bình an': 'peace',
    'binh an': 'peace',
    'peace': 'peace',

    // Tu tập
    'tu tập': 'practice',
    'tu tap': 'practice',
    'practice': 'practice',

    // Khác
    'khác': 'other',
    'khac': 'other',
    'other': 'other',
  };

  const normalized =
    categoryMap[value];

  if (!normalized) {
    throw new Error(
      `Category quote không hợp lệ: "${category}"`
    );
  }

  return normalized;
}

// ========================================
// CHUẨN HÓA OBJECT ĐỂ SO SÁNH
// ========================================

function normalizeValue(value) {
  if (Array.isArray(value)) {
    return value.map(normalizeValue);
  }

  if (
    value !== null &&
    typeof value === 'object'
  ) {
    const normalized = {};

    for (
      const key of Object.keys(value).sort()
    ) {
      normalized[key] =
        normalizeValue(value[key]);
    }

    return normalized;
  }

  return value;
}

// ========================================
// SEED QUOTES
// ========================================

async function seedQuotes() {
  const filePath = path.join(
    __dirname,
    '../../data/quotes/quotes.json'
  );

  if (!fs.existsSync(filePath)) {
    throw new Error(
      `Không tìm thấy quotes.json tại: ${filePath}`
    );
  }

  const rawData =
    fs.readFileSync(filePath, 'utf8');

  const quotes =
    JSON.parse(rawData);

  if (!Array.isArray(quotes)) {
    throw new Error(
      'quotes.json phải chứa một mảng.'
    );
  }

  if (quotes.length === 0) {
    console.log(
      'Không có dữ liệu quote để seed.'
    );

    return;
  }

  const codeSet = new Set();

  let inserted = 0;
  let updated = 0;
  let unchanged = 0;

  for (const quote of quotes) {
    // ==========================
    // VALIDATE
    // ==========================

    if (!quote.code) {
      throw new Error(
        'Có quote thiếu trường code.'
      );
    }

    if (!quote.content) {
      throw new Error(
        `Quote "${quote.code}" thiếu content.`
      );
    }

    const normalizedCode =
      quote.code
        .trim()
        .toLowerCase();

    if (codeSet.has(normalizedCode)) {
      throw new Error(
        `Code quote bị trùng: ${normalizedCode}`
      );
    }

    codeSet.add(normalizedCode);

    // ==========================
    // PAYLOAD
    // ==========================

    const payload = {
      ...quote,

      code: normalizedCode,

      category:
        normalizeCategory(
          quote.category
        ),
    };

    delete payload._id;
    delete payload.createdAt;
    delete payload.updatedAt;
    delete payload.__v;

    // ==========================
    // TÌM QUOTE HIỆN TẠI
    // ==========================

    const existing =
      await Quote.findOne({
        code: normalizedCode,
      }).lean();

    // ==========================
    // CHƯA CÓ -> INSERT
    // ==========================

    if (!existing) {
      await Quote.create(payload);

      inserted++;

      continue;
    }

    // ==========================
    // SO SÁNH
    // ==========================

    const existingData = {};

    for (
      const key of Object.keys(payload)
    ) {
      existingData[key] =
        existing[key];
    }

    const isUnchanged =
      JSON.stringify(
        normalizeValue(existingData)
      ) ===
      JSON.stringify(
        normalizeValue(payload)
      );

    if (isUnchanged) {
      unchanged++;

      continue;
    }

    // ==========================
    // UPDATE
    // ==========================

    await Quote.updateOne(
      {
        code: normalizedCode,
      },
      {
        $set: payload,
      },
      {
        runValidators: true,
      }
    );

    updated++;
  }

  console.log('');
  console.log(
    'Seed quotes thành công'
  );

  console.log(
    '----------------------------'
  );

  console.log(
    `Tổng dữ liệu : ${quotes.length}`
  );

  console.log(
    `Thêm mới     : ${inserted}`
  );

  console.log(
    `Cập nhật     : ${updated}`
  );

  console.log(
    `Không đổi    : ${unchanged}`
  );
}

module.exports = seedQuotes;

// ========================================
// CHẠY RIÊNG FILE NÀY
// ========================================

if (require.main === module) {
  (async () => {
    try {
      await connectDatabase();

      await seedQuotes();

      await mongoose.connection.close();

      console.log(
        'Đã đóng kết nối MongoDB.'
      );

      process.exit(0);
    } catch (error) {
      console.error('');

      console.error(
        'Seed quotes thất bại:'
      );

      console.error(
        error.message
      );

      if (
        mongoose.connection.readyState !== 0
      ) {
        await mongoose.connection.close();
      }

      process.exit(1);
    }
  })();
}
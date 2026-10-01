const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

const Scripture = require('../models/scripture.model');
const connectDatabase = require('../config/database');

dotenv.config({
  path: path.join(__dirname, '../../.env'),
});

// ==============================
// TẠO SLUG
// ==============================
function createSlug(text) {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

// ==============================
// CHUẨN HÓA TYPE
// ==============================
function normalizeType(type) {
  if (!type) {
    throw new Error(
      'Scripture thiếu trường type.'
    );
  }

  const value = type
    .trim()
    .toLowerCase();

  const typeMap = {
    kinh: 'Kinh',
    sutra: 'Kinh',

    'chú': 'Chú',
    chu: 'Chú',
    mantra: 'Chú',
  };

  const normalized = typeMap[value];

  if (!normalized) {
    throw new Error(
      `Loại kinh/chú không hợp lệ: "${type}"`
    );
  }

  return normalized;
}

// ==============================
// CHUẨN HÓA OBJECT ĐỂ SO SÁNH
// ==============================
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

// ==============================
// SEED SCRIPTURES
// ==============================
async function seedScriptures() {
  const filePath = path.join(
    __dirname,
    '../../data/kinh_phat/scriptures.json'
  );

  // Kiểm tra file tồn tại
  if (!fs.existsSync(filePath)) {
    throw new Error(
      `Không tìm thấy scriptures.json tại: ${filePath}`
    );
  }

  // Đọc JSON
  const rawData = fs.readFileSync(
    filePath,
    'utf8'
  );

  const scriptures = JSON.parse(rawData);

  // Phải là array
  if (!Array.isArray(scriptures)) {
    throw new Error(
      'scriptures.json phải chứa một mảng.'
    );
  }

  // Không có dữ liệu
  if (scriptures.length === 0) {
    console.log(
      'Không có dữ liệu kinh/chú để seed.'
    );

    return;
  }

  // Kiểm tra slug trùng trong JSON
  const slugSet = new Set();

  let inserted = 0;
  let updated = 0;
  let unchanged = 0;

  for (const scripture of scriptures) {
    // ==========================
    // VALIDATE DỮ LIỆU
    // ==========================

    if (!scripture.title) {
      throw new Error(
        'Có dữ liệu kinh/chú thiếu title.'
      );
    }

    if (!scripture.content) {
      throw new Error(
        `"${scripture.title}" thiếu content.`
      );
    }

    // ==========================
    // TẠO / CHUẨN HÓA SLUG
    // ==========================

    const normalizedSlug = createSlug(
      scripture.slug ||
      scripture.title
    );

    if (!normalizedSlug) {
      throw new Error(
        `Không thể tạo slug cho "${scripture.title}".`
      );
    }

    // Kiểm tra slug trùng trong JSON
    if (slugSet.has(normalizedSlug)) {
      throw new Error(
        `Slug kinh/chú bị trùng: ${normalizedSlug}`
      );
    }

    slugSet.add(normalizedSlug);

    // ==========================
    // TẠO PAYLOAD
    // ==========================

    const payload = {
      ...scripture,

      slug: normalizedSlug,

      type: normalizeType(
        scripture.type
      ),
    };

    // Không cho JSON ghi đè
    // các field do MongoDB quản lý
    delete payload._id;
    delete payload.createdAt;
    delete payload.updatedAt;
    delete payload.__v;

    // ==========================
    // TÌM DỮ LIỆU HIỆN TẠI
    // ==========================

    const existing =
      await Scripture.findOne({
        slug: normalizedSlug,
      }).lean();

    // ==========================
    // CHƯA TỒN TẠI -> INSERT
    // ==========================

    if (!existing) {
      await Scripture.create(payload);

      inserted++;

      continue;
    }

    // ==========================
    // SO SÁNH DỮ LIỆU
    // ==========================

    const existingData = {};

    for (
      const key of Object.keys(payload)
    ) {
      existingData[key] =
        existing[key];
    }

    const normalizedExisting =
      normalizeValue(existingData);

    const normalizedPayload =
      normalizeValue(payload);

    const isUnchanged =
      JSON.stringify(
        normalizedExisting
      ) ===
      JSON.stringify(
        normalizedPayload
      );

    // ==========================
    // KHÔNG THAY ĐỔI
    // ==========================

    if (isUnchanged) {
      unchanged++;

      continue;
    }

    // ==========================
    // CÓ THAY ĐỔI -> UPDATE
    // ==========================

    await Scripture.updateOne(
      {
        slug: normalizedSlug,
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

  // ==============================
  // KẾT QUẢ
  // ==============================

  console.log('');
  console.log(
    'Seed kinh/chú thành công'
  );

  console.log(
    '----------------------------'
  );

  console.log(
    `Tổng dữ liệu : ${scriptures.length}`
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

// Cho seed-all.js sử dụng
module.exports = seedScriptures;

// ==============================
// CHẠY TRỰC TIẾP FILE NÀY
// ==============================
if (require.main === module) {
  (async () => {
    try {
      await connectDatabase();

      await seedScriptures();

      await mongoose.connection.close();

      console.log(
        'Đã đóng kết nối MongoDB.'
      );

      process.exit(0);
    } catch (error) {
      console.error('');

      console.error(
        'Seed kinh/chú thất bại:'
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
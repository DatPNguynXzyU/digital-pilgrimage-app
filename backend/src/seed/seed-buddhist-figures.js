const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

const BuddhistFigure =
  require('../models/buddhist-figure.model');

const connectDatabase =
  require('../config/database');

dotenv.config({
  path: path.join(__dirname, '../../.env'),
});
function normalizeCategory(category) {
  if (!category) {
    return 'other';
  }

  const value = category
    .trim()
    .toLowerCase();

  const categoryMap = {
    // Phật
    'phật': 'buddha',
    'buddha': 'buddha',

    // Bồ Tát
    'bồ tát': 'bodhisattva',
    'bồ-tát': 'bodhisattva',
    'bodhisattva': 'bodhisattva',

    // A La Hán
    'a la hán': 'arhat',
    'la hán': 'arhat',
    'arhat': 'arhat',

    // Tổ sư
    'tổ': 'patriarch',
    'tổ sư': 'patriarch',
    'patriarch': 'patriarch',

    // Hộ pháp
    'hộ pháp': 'guardian',
    'guardian': 'guardian',

    // Khác
    'khác': 'other',
    'other': 'other',
  };

  const normalized = categoryMap[value];

  if (!normalized) {
    throw new Error(
      `Category không hợp lệ: "${category}"`
    );
  }

  return normalized;
}
async function seedBuddhistFigures() {
  const filePath = path.join(
    __dirname,
    '../../data/phat/buddhist_figures.json'
  );

  if (!fs.existsSync(filePath)) {
    throw new Error(
      `Không tìm thấy buddhist_figures.json tại: ${filePath}`
    );
  }

  const rawData = fs.readFileSync(
    filePath,
    'utf8'
  );

  const figures = JSON.parse(rawData);

  if (!Array.isArray(figures)) {
    throw new Error(
      'buddhist_figures.json phải chứa một mảng.'
    );
  }

  if (figures.length === 0) {
    console.log(
      'Không có dữ liệu Phật/Bồ Tát để seed.'
    );
    return;
  }

  const slugSet = new Set();

  let inserted = 0;
  let updated = 0;
  let unchanged = 0;

  for (const figure of figures) {
    if (!figure.name) {
      throw new Error(
        'Có dữ liệu Phật/Bồ Tát thiếu name.'
      );
    }

    if (!figure.slug) {
      throw new Error(
        `"${figure.name}" thiếu slug.`
      );
    }

    const normalizedSlug =
      figure.slug.trim().toLowerCase();

    if (slugSet.has(normalizedSlug)) {
      throw new Error(
        `Slug bị trùng: ${normalizedSlug}`
      );
    }

    slugSet.add(normalizedSlug);

    const payload = {
  ...figure,

  slug: normalizedSlug,

  category: normalizeCategory(
    figure.category
  ),
};

    delete payload._id;
    delete payload.createdAt;
    delete payload.updatedAt;
    delete payload.__v;

    const result =
      await BuddhistFigure.updateOne(
        {
          slug: normalizedSlug,
        },
        {
          $set: payload,
        },
        {
          upsert: true,
          runValidators: true,
          setDefaultsOnInsert: true,
        }
      );

    if (result.upsertedCount > 0) {
      inserted++;
    } else if (result.modifiedCount > 0) {
      updated++;
    } else {
      unchanged++;
    }
  }

  console.log('');
  console.log(
    'Seed Phật/Bồ Tát thành công'
  );
  console.log(
    '----------------------------'
  );
  console.log(
    `Tổng dữ liệu : ${figures.length}`
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

module.exports = seedBuddhistFigures;

if (require.main === module) {
  (async () => {
    try {
      await connectDatabase();

      await seedBuddhistFigures();

      await mongoose.connection.close();

      console.log(
        'Đã đóng kết nối MongoDB.'
      );

      process.exit(0);
    } catch (error) {
      console.error('');
      console.error(
        'Seed Phật/Bồ Tát thất bại:'
      );
      console.error(error.message);

      if (
        mongoose.connection.readyState !== 0
      ) {
        await mongoose.connection.close();
      }

      process.exit(1);
    }
  })();
}
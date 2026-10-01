const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

const Temple = require('../models/temple.model');
const connectDatabase = require('../config/database');

dotenv.config({
  path: path.join(__dirname, '../../.env'),
});

async function seedTemples() {
  const filePath = path.join(
    __dirname,
    '../../data/chua/temples.json'
  );

  if (!fs.existsSync(filePath)) {
    throw new Error(
      `Không tìm thấy file temples.json tại: ${filePath}`
    );
  }

  const rawData = fs.readFileSync(filePath, 'utf8');
  const temples = JSON.parse(rawData);

  if (!Array.isArray(temples)) {
    throw new Error(
      'temples.json phải chứa một mảng dữ liệu.'
    );
  }

  if (temples.length === 0) {
    console.log('Không có dữ liệu chùa để seed.');
    return;
  }

  // Kiểm tra slug trùng trong chính file JSON
  const slugSet = new Set();

  let inserted = 0;
  let updated = 0;
  let unchanged = 0;

  for (const temple of temples) {
    if (!temple.name) {
      throw new Error(
        'Phát hiện một chùa thiếu trường name.'
      );
    }

    if (!temple.slug) {
      throw new Error(
        `Chùa "${temple.name}" thiếu slug.`
      );
    }

    const normalizedSlug = temple.slug
      .trim()
      .toLowerCase();

    if (slugSet.has(normalizedSlug)) {
      throw new Error(
        `Slug bị trùng trong temples.json: ${normalizedSlug}`
      );
    }

    slugSet.add(normalizedSlug);

    // Không cho file seed tự ý thay đổi các field hệ thống
    const payload = {
      ...temple,
      slug: normalizedSlug,
    };

    delete payload._id;
    delete payload.createdAt;
    delete payload.updatedAt;
    delete payload.__v;

    const result = await Temple.updateOne(
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
  console.log('Seed chùa thành công');
  console.log('----------------------------');
  console.log(`Tổng dữ liệu : ${temples.length}`);
  console.log(`Thêm mới     : ${inserted}`);
  console.log(`Cập nhật     : ${updated}`);
  console.log(`Không đổi    : ${unchanged}`);
}

// Cho phép seed-all.js import hàm này
module.exports = seedTemples;

// Cho phép chạy trực tiếp:
// npm run seed:temples
if (require.main === module) {
  (async () => {
    try {
      await connectDatabase();

      await seedTemples();

      await mongoose.connection.close();

      console.log('Đã đóng kết nối MongoDB.');
      process.exit(0);
    } catch (error) {
      console.error('');
      console.error('Seed chùa thất bại:');
      console.error(error.message);

      if (mongoose.connection.readyState !== 0) {
        await mongoose.connection.close();
      }

      process.exit(1);
    }
  })();
}
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

async function seedHolidays() {
  const filePath = path.join(
    __dirname,
    '../../data/le_phat_dan/holidays.json'
  );

  const rawData = fs.readFileSync(filePath, 'utf8');
  const holidays = JSON.parse(rawData);

  if (!Array.isArray(holidays)) {
    throw new Error(
      'holidays.json phải chứa một mảng dữ liệu.'
    );
  }

  if (holidays.length === 0) {
    console.log('Không có dữ liệu ngày lễ để seed.');
    return;
  }

  const operations = holidays.map((holiday) => {
    if (!holiday.slug) {
      throw new Error(
        `Ngày lễ "${holiday.name ?? 'Không tên'}" thiếu slug.`
      );
    }

    return {
      updateOne: {
        filter: {
          slug: holiday.slug,
        },
        update: {
          $set: holiday,
        },
        upsert: true,
      },
    };
  });

  const result = await mongoose.connection
    .collection('buddhist_holidays')
    .bulkWrite(operations);

  console.log('Seed ngày lễ Phật giáo thành công');
  console.log(`- Tổng dữ liệu: ${holidays.length}`);
  console.log(`- Thêm mới: ${result.upsertedCount}`);
  console.log(`- Cập nhật: ${result.modifiedCount}`);
}

module.exports = seedHolidays;
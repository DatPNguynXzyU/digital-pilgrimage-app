const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

async function seedTemples() {
  const filePath = path.join(
    __dirname,
    '../../data/chua/temples.json'
  );

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

  const operations = temples.map((temple) => {
    if (!temple.slug) {
      throw new Error(
        `Chùa "${temple.name ?? 'Không tên'}" thiếu slug.`
      );
    }

    return {
      updateOne: {
        filter: {
          slug: temple.slug,
        },
        update: {
          $set: temple,
        },
        upsert: true,
      },
    };
  });

  const result = await mongoose.connection
    .collection('temples')
    .bulkWrite(operations);

  console.log('Seed chùa thành công');
  console.log(`- Tổng dữ liệu: ${temples.length}`);
  console.log(`- Thêm mới: ${result.upsertedCount}`);
  console.log(`- Cập nhật: ${result.modifiedCount}`);
}

module.exports = seedTemples;
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

async function seedScriptures() {
  const filePath = path.join(
    __dirname,
    '../../data/kinh_phat/scriptures.json'
  );

  const rawData = fs.readFileSync(filePath, 'utf8');
  const scriptures = JSON.parse(rawData);

  if (!Array.isArray(scriptures)) {
    throw new Error(
      'scriptures.json phải chứa một mảng dữ liệu.'
    );
  }

  if (scriptures.length === 0) {
    console.log('Không có dữ liệu kinh Phật để seed.');
    return;
  }

  const operations = scriptures.map((scripture) => {
    if (!scripture.slug) {
      throw new Error(
        `Kinh "${scripture.title ?? 'Không tên'}" thiếu slug.`
      );
    }

    return {
      updateOne: {
        filter: {
          slug: scripture.slug,
        },
        update: {
          $set: scripture,
        },
        upsert: true,
      },
    };
  });

  const result = await mongoose.connection
    .collection('scriptures')
    .bulkWrite(operations);

  console.log('Seed kinh Phật thành công');
  console.log(`- Tổng dữ liệu: ${scriptures.length}`);
  console.log(`- Thêm mới: ${result.upsertedCount}`);
  console.log(`- Cập nhật: ${result.modifiedCount}`);
}

module.exports = seedScriptures;
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

async function seedBuddhistFigures() {
  const filePath = path.join(
    __dirname,
    '../../data/phat_to/buddhist_figures.json'
  );

  const rawData = fs.readFileSync(filePath, 'utf8');
  const figures = JSON.parse(rawData);

  if (!Array.isArray(figures)) {
    throw new Error(
      'buddhist_figures.json phải chứa một mảng dữ liệu.'
    );
  }

  if (figures.length === 0) {
    console.log('Không có dữ liệu Phật/Tổ để seed.');
    return;
  }

  const operations = figures.map((figure) => {
    if (!figure.slug) {
      throw new Error(
        `Dữ liệu "${figure.name ?? 'Không tên'}" thiếu slug.`
      );
    }

    return {
      updateOne: {
        filter: {
          slug: figure.slug,
        },
        update: {
          $set: figure,
        },
        upsert: true,
      },
    };
  });

  const result = await mongoose.connection
    .collection('buddhist_figures')
    .bulkWrite(operations);

  console.log('Seed dữ liệu Phật/Tổ thành công');
  console.log(`- Tổng dữ liệu: ${figures.length}`);
  console.log(`- Thêm mới: ${result.upsertedCount}`);
  console.log(`- Cập nhật: ${result.modifiedCount}`);
}

module.exports = seedBuddhistFigures;
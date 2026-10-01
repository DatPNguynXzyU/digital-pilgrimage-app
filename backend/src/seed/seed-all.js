const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');


const connectDatabase =
  require('../config/database');

const seedTemples =
  require('./seed-temples');

const seedBuddhistFigures =
  require('./seed-buddhist-figures');

const seedScriptures =
  require('./seed-scriptures');

const seedQuotes =
  require('./seed-quotes');
dotenv.config({
  path: path.join(__dirname, '../../.env'),
});

async function seedAll() {
  try {
    console.log('');
    console.log('==============================');
    console.log('   BẮT ĐẦU SEED DATABASE');
    console.log('==============================');

    // Chỉ kết nối MongoDB 1 lần
    await connectDatabase();

    // ==========================
    // 1. CHÙA
    // ==========================
    console.log('');
    console.log('1. Seed dữ liệu chùa');
    console.log('------------------------------');

    await seedTemples();

    // ==========================
    // 2. PHẬT / BỒ TÁT
    // ==========================
    console.log('');
    console.log('2. Seed dữ liệu Phật/Bồ Tát');
    console.log('------------------------------');

    await seedBuddhistFigures();

    // ==========================
    // 3. KINH / CHÚ
    // ==========================
    console.log('');
    console.log('3. Seed dữ liệu kinh/chú');
    console.log('------------------------------');

    await seedScriptures();

    console.log('');
    console.log('4. Seed dữ liệu quotes');
    console.log('------------------------------');

await seedQuotes();

    console.log('');
    console.log('==============================');
    console.log('   SEED DATABASE HOÀN TẤT');
    console.log('==============================');
  } catch (error) {
    console.error('');
    console.error('SEED DATABASE THẤT BẠI');
    console.error('------------------------------');
    console.error(error.message);

    process.exitCode = 1;
  } finally {
    if (
      mongoose.connection.readyState !== 0
    ) {
      await mongoose.connection.close();

      console.log('');
      console.log(
        'Đã đóng kết nối MongoDB.'
      );
    }
  }
}

seedAll();
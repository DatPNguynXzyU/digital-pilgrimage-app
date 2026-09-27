require('dotenv').config();

const mongoose = require('mongoose');

const connectDatabase = require('../config/database');

const seedScriptures = require('./seed-scriptures');
const seedTemples = require('./seed-temples');
const seedHolidays = require('./seed-holidays');

async function seedAll() {
  try {
    console.log('==============================');
    console.log('BẮT ĐẦU SEED DATABASE');
    console.log('==============================');

    await connectDatabase();

    console.log('');
    console.log('1. Seed Kinh Phật');
    await seedScriptures();

    console.log('');
    console.log('2. Seed Chùa');
    await seedTemples();

    console.log('');
    console.log('3. Seed ngày lễ Phật giáo');
    await seedHolidays();

    console.log('');
    console.log('==============================');
    console.log('SEED DATABASE HOÀN TẤT');
    console.log('==============================');
  } catch (error) {
    console.error('');
    console.error('Seed database thất bại');
    console.error(error);
    process.exitCode = 1;
  } finally {
    await mongoose.connection.close();

    console.log('');
    console.log('Đã đóng kết nối MongoDB.');
  }
}

seedAll();
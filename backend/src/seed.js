require('dotenv').config();

const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

const connectDatabase = require('./config/database');
const Scripture = require('./models/scripture.model');

function readJson(relativePath) {
  const filePath = path.join(__dirname, relativePath);

  const rawData = fs.readFileSync(
    filePath,
    'utf8'
  );

  return JSON.parse(rawData);
}

async function seedScriptures() {
  try {
    await connectDatabase();

    const scriptures = readJson(
      '../data/scriptures.json'
    );

    for (const scripture of scriptures) {
      await Scripture.updateOne(
        {
          slug: scripture.slug,
        },
        {
          $set: scripture,
        },
        {
          upsert: true,
        }
      );
    }

    console.log(
      'Seed scriptures successfully'
    );
  } catch (error) {
    console.error(
      'Seed failed:',
      error
    );
  } finally {
    await mongoose.connection.close();
  }
}

seedScriptures();
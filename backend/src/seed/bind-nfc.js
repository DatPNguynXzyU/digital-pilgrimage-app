const mongoose = require('mongoose');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({
  path: path.join(__dirname, '../../.env'),
});

const connectDatabase = require('../config/database');
const NfcTag = require('../models/nfc-tag.model');
const Temple = require('../models/temple.model');

async function main() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.log('Cách dùng: node src/seed/bind-nfc.js <UID> <SLUG_HOAC_ID_HOAC_TEN_CHUA>');
    console.log('Ví dụ: node src/seed/bind-nfc.js 04A1B2C3D4E5 chua-giac-lam');
    process.exit(1);
  }

  const rawUid = args[0];
  const templeQuery = args[1].trim();

  const uid = rawUid.replace(/[^0-9a-fA-F]/g, '').toUpperCase();
  if (!uid) {
    console.error('Lỗi: UID NFC không hợp lệ!');
    process.exit(1);
  }

  await connectDatabase();

  try {
    let temple = null;
    if (mongoose.Types.ObjectId.isValid(templeQuery)) {
      temple = await Temple.findById(templeQuery);
    }
    if (!temple) {
      temple = await Temple.findOne({ slug: templeQuery.toLowerCase() });
    }
    if (!temple) {
      temple = await Temple.findOne({
        name: { $regex: templeQuery, $options: 'i' },
      });
    }

    if (!temple) {
      console.error(`Không tìm thấy chùa phù hợp với: "${templeQuery}"`);
      const all = await Temple.find({}, { name: 1, slug: 1 }).lean();
      console.log('Danh sách slug các chùa hiện có:');
      all.forEach((t) => console.log(`- ${t.slug} (${t.name})`));
      process.exit(1);
    }

    const nfcTag = await NfcTag.findOneAndUpdate(
      { uid },
      {
        uid,
        templeId: temple._id,
        label: `Thẻ NFC ${temple.name}`,
        status: 'active',
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    console.log('');
    console.log('==============================================');
    console.log('LIÊN KẾT THẺ NFC THÀNH CÔNG:');
    console.log(`- UID: ${nfcTag.uid}`);
    console.log(`- Chùa: ${temple.name} (Slug: ${temple.slug})`);
    console.log(`- Temple ID: ${temple._id}`);
    console.log('==============================================');
  } catch (err) {
    console.error('Lỗi:', err.message);
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
}

main();


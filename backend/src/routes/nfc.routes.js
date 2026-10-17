const express = require('express');
const {
  scanNfc,
  getTempleByTagUid,
  getAllNfcTags,
} = require('../controllers/nfc.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = express.Router();

// 1. Tra cứu thông tin chùa qua UID thẻ NFC (công khai)
router.get('/temple/:uid', getTempleByTagUid);

// 2. Lấy danh sách thẻ NFC đã liên kết
router.get('/tags', getAllNfcTags);

// 3. Check-in thẻ NFC theo slug chùa và UID (yêu cầu đăng nhập)
router.post('/scan', authMiddleware, scanNfc);

module.exports = router;
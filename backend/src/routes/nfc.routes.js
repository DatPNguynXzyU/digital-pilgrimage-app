const express =
  require('express');

const {
  scanNfc,
} = require(
  '../controllers/nfc.controller'
);

const authMiddleware =
  require(
    '../middleware/auth.middleware'
  );

const router =
  express.Router();

// Tất cả API NFC đều yêu cầu đăng nhập
router.use(authMiddleware);

// POST /api/nfc/scan
router.post(
  '/scan',
  scanNfc
);

module.exports = router;
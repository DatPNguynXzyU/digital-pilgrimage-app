const express = require('express');

const authMiddleware =
  require('../middleware/auth.middleware');

const {
  getVisitHistory,
  getVisitedTemples,
  getPilgrimageStats,
  getTempleStamps,
} = require(
  '../controllers/pilgrimage.controller'
);

const router = express.Router();

// Tất cả API hành hương đều cần đăng nhập
router.use(authMiddleware);

// Lịch sử từng lần viếng
router.get(
  '/history',
  getVisitHistory
);

// Danh sách chùa đã đi
router.get(
  '/temples',
  getVisitedTemples
);

// Thống kê
router.get(
  '/stats',
  getPilgrimageStats
);

// Sổ tem
router.get(
  '/stamps',
  getTempleStamps
);

module.exports = router;
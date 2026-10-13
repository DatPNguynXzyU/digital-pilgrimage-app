const express =
  require('express');

const authMiddleware =
  require(
    '../middleware/auth.middleware'
  );

const {
  getVisitHistory,
  getVisitedTemples,
  getPilgrimageStats,
} = require(
  '../controllers/pilgrimage.controller'
);

const router =
  express.Router();

// Tất cả đều yêu cầu đăng nhập
router.use(authMiddleware);

// Lịch sử từng lần viếng
router.get(
  '/history',
  getVisitHistory
);

// Danh sách chùa đã đi + số lần
router.get(
  '/temples',
  getVisitedTemples
);

// Thống kê tổng quan
router.get(
  '/stats',
  getPilgrimageStats
);

module.exports = router;
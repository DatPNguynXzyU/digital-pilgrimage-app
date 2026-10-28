const router = require('express').Router();
const controller = require('../controllers/nfc-admin.controller');
router.use(require('../middleware/auth.middleware'));
router.use((req, res, next) => {
  res.set('Cache-Control', 'no-store');
  if (req.user.role !== 'admin') return res.status(403).json({ success: false, message: 'Chỉ quản trị viên được xem thống kê NFC.' });
  next();
});
router.get('/statistics', controller.statistics);
router.get('/temples', controller.temples);
router.post('/events', controller.createEvent);
module.exports = router;

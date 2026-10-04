const express =
  require('express');

const {
  getTemples,
  getTempleBySlug,
  getTempleById,
} =
  require('../controllers/temple.controller');

const router =
  express.Router();

router.get(
  '/',
  getTemples
);

router.get('/id/:id', getTempleById);

router.get(
  '/:slug',
  getTempleBySlug
);

module.exports = router;
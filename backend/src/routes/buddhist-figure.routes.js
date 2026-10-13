const express = require('express');

const {
  getBuddhistFigures,
  getBuddhistFigureBySlug,
} = require(
  '../controllers/buddhist-figure.controller'
);

const router =
  express.Router();

// GET /api/buddhist-figures
router.get(
  '/',
  getBuddhistFigures
);

// GET /api/buddhist-figures/:slug
router.get(
  '/:slug',
  getBuddhistFigureBySlug
);

module.exports = router;
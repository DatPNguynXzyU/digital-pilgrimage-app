const express = require('express');

const {
  getScriptures,
  getScriptureBySlug,
} = require('../controllers/scripture.controller');

const router = express.Router();

router.get('/', getScriptures);

router.get('/:slug', getScriptureBySlug);

module.exports = router;
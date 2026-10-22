const router = require('express').Router();
const Quote = require('../models/quote.model');
const { resolveQuote } = require('../utils/quote-content');

router.get('/random', async (req, res) => {
  const exclude = req.query.exclude;
  if (exclude !== undefined && (typeof exclude !== 'string' || exclude.length > 100)) {
    return res.status(400).json({ success: false, message: 'Mã trích dẫn không hợp lệ.' });
  }
  try {
    const filter = { isActive: true };
    if (exclude) filter.code = { $ne: exclude };
    const projection = { _id: 0, code: 1, content: 1, author: 1, source: 1 };
    let [quote] = await Quote.aggregate([
      { $match: filter }, { $sample: { size: 1 } }, { $project: projection },
    ]);
    if (!quote && exclude) {
      [quote] = await Quote.aggregate([
        { $match: { isActive: true } }, { $sample: { size: 1 } }, { $project: projection },
      ]);
    }
    res.set('Cache-Control', 'no-store');
    return res.json({ success: true, data: resolveQuote(quote, exclude) || null });
  } catch (error) {
    console.error('Quote error:', error);
    return res.status(500).json({ success: false, message: 'Không thể tải câu Phật ngôn.' });
  }
});
module.exports = router;

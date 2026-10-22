const { randomInt } = require('node:crypto');
const catalog = require('../../data/quotes/quotes.json');

// Older databases were seeded with these demo strings. Do not display them
// as scripture or rewrite real user-managed content in the database.
const placeholders = new Set(['Tâm dẫn đầu các pháp...', 'Một câu trích dẫn khác...']);
function resolveQuote(quote, exclude) {
  if (!quote || !placeholders.has(quote.content?.trim())) return quote;
  const candidates = catalog.filter(q => q.isActive && q.code !== exclude);
  if (!candidates.length) return null;
  const { code, content, source, author } = candidates[randomInt(candidates.length)];
  return { code, content, source, author };
}
module.exports = { resolveQuote };

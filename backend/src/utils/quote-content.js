const { randomInt } = require('node:crypto');
const catalog = require('../../data/quotes/quotes.json');

// Older databases were seeded with these demo strings. Do not display them
// as scripture or rewrite real user-managed content in the database.
const placeholders = new Set(['Tâm dẫn đầu các pháp...', 'Một câu trích dẫn khác...']);
const isPlaceholder = content => placeholders.has(content?.trim()) ||
  /^Nội dung câu kệ \d+$/u.test(content?.trim() || '');
function resolveQuote(quote, exclude) {
  if (!quote || !isPlaceholder(quote.content)) return quote;
  const candidates = catalog.filter(q => q.isActive && q.code !== exclude &&
    q.content?.trim() && !isPlaceholder(q.content));
  if (!candidates.length) return null;
  const { code, content, source, author } = candidates[randomInt(candidates.length)];
  return { code, content, source, author };
}
module.exports = { resolveQuote };

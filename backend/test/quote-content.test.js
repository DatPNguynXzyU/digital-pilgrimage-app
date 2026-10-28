const test = require('node:test');
const assert = require('node:assert/strict');
const { resolveQuote } = require('../src/utils/quote-content');
const catalog = require('../data/quotes/quotes.json');

test('legacy demo quotes resolve to complete verses and never repeat the excluded code', () => {
  for (const content of ['Tâm dẫn đầu các pháp...', 'Một câu trích dẫn khác...']) {
    let previous = 'quote-001';
    for (let i = 0; i < 30; i++) {
      const quote = resolveQuote({ code: 'quote-002', content }, previous);
      assert.notEqual(quote.code, previous);
      // The imported catalog stores prose; Flutter restores matching verse
      // line breaks for display. The API must preserve the catalog wording.
      const expected = catalog.find(item => item.code === quote.code && item.isActive);
      assert.ok(expected, 'fallback must select an active catalog entry');
      assert.deepEqual(quote, {
        code: expected.code,
        content: expected.content,
        source: expected.source,
        author: expected.author,
      });
      assert.ok(quote.content.length > 40, 'fallback must contain a full quote');
      previous = quote.code;
    }
  }
});
test('empty collections and editorial content remain unchanged', () => {
  assert.equal(resolveQuote(null), null);
  const quote = { code: 'custom', content: 'Nội dung biên tập', source: 'Nguồn' };
  assert.equal(resolveQuote(quote), quote);
});

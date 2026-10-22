const test = require('node:test');
const assert = require('node:assert/strict');
const { resolveQuote } = require('../src/utils/quote-content');

test('legacy demo quotes resolve to complete verses and never repeat the excluded code', () => {
  for (const content of ['Tâm dẫn đầu các pháp...', 'Một câu trích dẫn khác...']) {
    let previous = 'quote-001';
    for (let i = 0; i < 30; i++) {
      const quote = resolveQuote({ code: 'quote-002', content }, previous);
      assert.notEqual(quote.code, previous);
      assert.match(quote.source, /kệ \d+/);
      assert.ok(quote.content.includes('\n'));
      previous = quote.code;
    }
  }
});
test('empty collections and editorial content remain unchanged', () => {
  assert.equal(resolveQuote(null), null);
  const quote = { code: 'custom', content: 'Nội dung biên tập', source: 'Nguồn' };
  assert.equal(resolveQuote(quote), quote);
});

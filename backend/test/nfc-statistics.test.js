const { test } = require('node:test');
const assert = require('node:assert/strict');
const { range } = require('../src/controllers/nfc-admin.controller');
test('NFC reporting dates are inclusive Vietnam days with bounded range', () => {
  const result = range({ from: '2024-05-01', to: '2024-05-02' });
  assert.equal(result.start.toISOString(), '2024-04-30T17:00:00.000Z');
  assert.equal(result.end.toISOString(), '2024-05-02T17:00:00.000Z');
  assert.equal(range({}, new Date('2024-05-01T18:00:00Z')).to, '2024-05-02');
  for (const query of [{ from: '2024-02-30' }, { from: [] }, { to: '' },
    { templeId: { $ne: null } }, { from: '2024-01-01', to: '2025-01-01' }]) {
    assert.throws(() => range(query));
  }
  assert.equal(range({ from: '2024-01-01', to: '2024-12-31' }).from, '2024-01-01');
});

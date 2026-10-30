const { test } = require('node:test');
const assert = require('node:assert/strict');
const spec = require('../src/config/openapi');
const app = require('../src/app');

test('Swagger HTML, local assets and OpenAPI JSON are served without database access', async () => {
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    const response = await fetch(base + '/api-docs.json');
    assert.equal(response.status, 200);
    const json = await response.json();
    assert.equal(json.openapi, '3.0.3');
    assert.equal(json.servers[0].url, '/api');
    const html = await fetch(base + '/api-docs/');
    assert.equal(html.status, 200);
    assert.match(await html.text(), /swagger-ui/);
    const asset = await fetch(base + '/api-docs/swagger-ui.css');
    assert.equal(asset.status, 200);
    assert.match(asset.headers.get('content-type'), /css/);
  } finally {
    server.closeAllConnections();
    await new Promise(resolve => server.close(resolve));
  }
});

test('private operations require bearer auth and path placeholders have parameters', () => {
  for (const [path, methods] of Object.entries(spec.paths)) {
    for (const operation of Object.values(methods)) {
      if (/^\/(admin|pilgrimage|calendar-events)\b/.test(path)) {
        assert.deepEqual(operation.security, [{ bearerAuth: [] }], path);
      }
      for (const match of path.matchAll(/\{([^}]+)\}/g)) {
        assert.ok(operation.parameters?.some(p => p.name === match[1] && p.in === 'path' && p.required), path);
      }
      assert.ok(Object.keys(operation.responses).some(code => /^2/.test(code)), path);
    }
  }
  assert.equal(spec.paths['/auth/avatar'].post.requestBody.content['multipart/form-data'].schema.properties.avatar.format, 'binary');
});

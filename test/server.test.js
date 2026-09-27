const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const app = require('../server');

describe('my-app', () => {
  it('GET / returns hello message', async () => {
    const res = await request(app).get('/');
    assert.equal(res.status, 200);
    assert.match(res.text, /Hello World from my container!/);
  });

  it('GET /health returns OK', async () => {
    const res = await request(app).get('/health');
    assert.equal(res.status, 200);
    assert.equal(res.text, 'OK');
  });
});

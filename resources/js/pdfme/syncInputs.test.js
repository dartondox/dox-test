import assert from 'node:assert/strict'
import test from 'node:test'
import { syncInputs } from './syncInputs.js'

const t = (...fields) => ({ schemas: [fields] })
const run = (inputs, a, b) => JSON.parse(syncInputs(JSON.stringify(inputs), a, b))

test('adds a new field with its content', () => {
  const out = run([{ a: 'x' }], t({ name: 'a', content: 'x' }), t({ name: 'a', content: 'x' }, { name: 'img', content: 'data:1' }))
  assert.deepEqual(out, [{ a: 'x', img: 'data:1' }])
})

test('drops a removed field and ignores readOnly', () => {
  const out = run([{ a: '1', b: '2' }], t({ name: 'a', content: '' }, { name: 'b', content: '' }), t({ name: 'a', content: '' }, { name: 'r', readOnly: true, content: 'z' }))
  assert.deepEqual(out, [{ a: '1' }])
})

test('keeps an edited value', () => {
  const out = run([{ a: 'mine' }], t({ name: 'a', content: 'old' }), t({ name: 'a', content: 'old2' }))
  assert.deepEqual(out, [{ a: 'mine' }])
})

test('follows new content when input still equals the old content', () => {
  const out = run([{ a: 'old' }, { a: 'mine' }], t({ name: 'a', content: 'old' }), t({ name: 'a', content: 'new' }))
  assert.deepEqual(out, [{ a: 'new' }, { a: 'mine' }])
})

test('rename drops the old key and adds the new one', () => {
  const out = run([{ a: 'mine' }], t({ name: 'a', content: 'c' }), t({ name: 'b', content: 'c' }))
  assert.deepEqual(out, [{ b: 'c' }])
})

test('invalid JSON or wrong shape gives null', () => {
  assert.equal(syncInputs('[', t(), t()), null)
  assert.equal(syncInputs('{"a":1}', t(), t()), null)
})

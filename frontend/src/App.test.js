// Simple smoke test
test('basic math works', () => {
  expect(2 + 2).toBe(4);
});

test('environment is test', () => {
  expect(process.env.NODE_ENV).toBe('test');
});
// Small math helpers used to exercise Cairn's syntax-highlighted diffs.
//
// Kept deliberately long so diffs can span several hunks.

export function add(...values) {
  return values.reduce((acc, v) => acc + v, 0);
}

export function subtract(a, b) {
  return a - b;
}

export function multiply(a, b) {
  return a * b;
}

export function clamp(value, min, max) {
  if (min > max) throw new RangeError("min must not exceed max");
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

export function round(value, places = 0) {
  const f = 10 ** places;
  return Math.round(value * f) / f;
}

export function lerp(a, b, t) {
  return a + (b - a) * clamp(t, 0, 1);
}

export function sum(values) {
  return values.reduce((acc, v) => acc + v, 0);
}

export function mean(values) {
  if (values.length === 0) return 0;
  return sum(values) / values.length;
}

export const PI = Math.PI;
export const TAU = PI * 2;
export const E = Math.E;

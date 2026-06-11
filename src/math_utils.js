// Small math helpers used to exercise Cairn's syntax-highlighted diffs.
//
// Kept deliberately long so diffs can span several hunks.

export function add(a, b) {
  return a + b;
}

export function subtract(a, b) {
  return a - b;
}

export function multiply(a, b) {
  return a * b;
}

export function clamp(value, min, max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
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

export const PI = 3.14159;
export const TAU = PI * 2;

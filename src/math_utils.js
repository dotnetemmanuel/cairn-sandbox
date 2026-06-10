// Small math helpers used to exercise Cairn's syntax-highlighted diffs.

export function add(a, b) {
  return a + b;
}

export function clamp(value, min, max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

export const PI = 3.14159;

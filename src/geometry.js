// Geometry helpers built on top of math_utils.

import { PI, clamp } from "./math_utils.js";

export function circleArea(radius) {
  return PI * radius * radius;
}

export function circleCircumference(radius) {
  return 2 * PI * radius;
}

export function rectangleArea(width, height) {
  return width * height;
}

export function distance(ax, ay, bx, by) {
  const dx = bx - ax;
  const dy = by - ay;
  return Math.sqrt(dx * dx + dy * dy);
}

export function clampPoint(x, y, bounds) {
  return {
    x: clamp(x, bounds.minX, bounds.maxX),
    y: clamp(y, bounds.minY, bounds.maxY),
  };
}

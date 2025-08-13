#ifndef INCLUDE_GBMS_TEST
#define INCLUDE_GBMS_TEST

// Debug patterns.

#include "sd.glsl"
#include "c.glsl"

// Draws a latency and smoothness test pattern. Includes timed elements, and elements that react to
// mouse position and movement.
vec4 debugLatency(
	vec2 p,
	vec2 size,
	vec2 mouse_position,
	u32 mouse_buttons,
	float seconds,
	float speed
) {
    if (mouse_buttons != 0) return vec4(1);
	float line2 = sdBox(
		p - vec2(mod(size.x * mod(seconds, 1.0 / speed) * speed, size.x), 0),
		vec2(1, size.y)
	);
	float box = sdBox(p - mouse_position, vec2(20, 20));
	float sd = opUnion(line2, box);
	return vec4(vec3(step(0, -sd)), 1);
}

#endif

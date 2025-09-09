#ifndef INCLUDE_GBMS_TEST
#define INCLUDE_GBMS_TEST

// Debug patterns.

#include "sd.glsl"
#include "c.glsl"

// Draws a latency and smoothness test pattern. Includes timed elements, and elements that react to
// mouse position and movement. `ab` can be used to specify which side of an AB test is being
// displayed, setting it to `true` will display `a` and `false` will display `b`.
vec4 debugLatency(
	vec2 p,
	vec2 size,
	vec2 mouse_position,
	u32 mouse_buttons,
	float seconds,
	float speed,
	u32 ab
) {
    if (mouse_buttons != 0) return vec4(1);
	float line2 = sdBox(
		p - vec2(mod(size.x * mod(seconds, 1.0 / speed) * speed, size.x), 0),
		vec2(1, size.y)
	);
	float box = sdBox(p - mouse_position, vec2(20, 20));
	float sd = opUnion(line2, box);

	switch (ab) {
		case 1: {
			sd = opUnion(sd, sdBox(p - vec2(40, 40), vec2(5, 20))); // Left vert
			sd = opUnion(sd, sdBox(p - vec2(60, 40), vec2(5, 20))); // Right vert
			sd = opUnion(sd, sdBox(p - vec2(45, 40), vec2(10, 5))); // Center horiz
			sd = opUnion(sd, sdBox(p - vec2(50, 20), vec2(10, 5))); // Top horiz
		} break;
		case 2: {
			sd = opUnion(sd, sdBox(p - vec2(40, 40), vec2(5, 20))); // Left vert
			sd = opUnion(sd, sdBox(p - vec2(60, 40), vec2(5, 20))); // Right vert
			sd = opUnion(sd, sdBox(p - vec2(45, 40), vec2(10, 5))); // Center horiz
			sd = opUnion(sd, sdBox(p - vec2(45, 20), vec2(15, 5))); // Top horiz
			sd = opUnion(sd, sdBox(p - vec2(45, 60), vec2(15, 5))); // Bottom horiz
		} break;

	}

	return vec4(vec3(step(0, -sd)), 1);
}

#endif

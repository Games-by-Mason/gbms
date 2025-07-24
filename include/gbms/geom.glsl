#ifndef INCLUDE_GBMS_GEOM
#define INCLUDE_GBMS_GEOM

#include "c.glsl"

f32 length2(f32 v) {
	return dot(v, v);
}

f32 length2(vec2 v) {
	return dot(v, v);
}

f32 length2(vec3 v) {
	return dot(v, v);
}

f32 length2(vec4 v) {
	return dot(v, v);
}

f32 outerProd(vec2 a, vec2 b) {
	return fma(a.x, b.y, -b.x * a.y);
}

vec2 geomProd(vec2 a, vec2 b) {
	return vec2(outerProd(a, b), dot(a, b));
}

f32 compSum(vec2 v) {
	return v.x + v.y;
}

f32 compSum(vec3 v) {
	return v.x + v.y + v.z;
}

f32 compSum(vec4 v) {
	return v.x + v.y + v.z + v.w;
}

// Returns a 2D rotor in (xy, a) form.
vec2 rotor(f32 rad) {
	f32 ha = rad * 0.5;
	return vec2(-sin(ha), cos(ha));
}

vec2 rotorInverse(vec2 r) {
	return vec2(-r.x, r.y);
}

vec2 rotorTimesVec(vec2 r, vec2 v) {
	vec2 xy = geomProd(v, r);
	return vec2(geomProd(xy, r));
}

mat2 rotorToMat(vec2 r) {
	vec2 inverse = rotorInverse(r);
	vec2 x = rotorTimesVec(inverse, vec2(1, 0));
	vec2 y = rotorTimesVec(inverse, vec2(0, 1));
	return mat2(x, y);
}

#endif

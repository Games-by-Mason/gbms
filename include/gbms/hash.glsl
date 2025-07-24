#ifndef INCLUDE_GBMS_HASH
#define INCLUDE_GBMS_HASH

// Provides a variety of hash functions.
//
// Use the named functions when you want a specific algorithm, use `hash` when you just want a
// balanced choice for your input type. Once the library stabilizes, the unnamed hash functions will
// only be modified by versioning their names or with major releases, since changing them could
// break existing effects.
//
// If your inputs are floats, you may convert them using `floatBitsToInt(...)`. However if they are
// whole number floats, you may get a better quality hash by instead casting to an integer type.
// Notably, `pcg3d` and `pcg4d` perform poorly on whole number floats that are bit casted. This can
// be revealed by taking the modulo of the result with a power of two as happens in a typical Perlin
// noise implementation.
//
// All provided functions are on the Pareto frontier of performance and quality according to this
// paper unless otherwise noted:
//
// https://jcgt.org/published/0009/03/02/
//
// These functions are mirrored in `geom`:
//
// https://github.com/Games-by-Mason/geom

#include "constants.glsl"
#include "c.glsl"

// Melissa O'Neill's PCG PRNG, adapted for use as a hash function.
u32 pcg(u32 s) {
    u32 state = s * 747796405u + 2891336453u;
    u32 word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

// Adapted from: https://jcgt.org/published/0009/03/02/
//
// Unclear if on the pareto frontier, but not sure what their recommendation is for 2 -> 2 hashes.
uvec2 pcg2d(uvec2 v) {
    v = v * 1664525u + 1013904223u;
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v >> 16u);
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v >> 16u);
    return v;
}

// Adapted from: https://jcgt.org/published/0009/03/02/
uvec3 pcg3d(uvec3 s) {
    s = s * 1664525u + 1013904223u;
    s.x += s.y * s.z;
    s.y += s.z * s.x;
    s.z += s.x * s.y;
    s ^= s >> 16u;
    s.x += s.y * s.z;
    s.y += s.z * s.x;
    s.z += s.x * s.y;
    return s;
}

// Adapted from: https://jcgt.org/published/0009/03/02/
uvec4 pcg4d(uvec4 s) {
    s = s * 1664525u + 1013904223u;
    s.x += s.y * s.w;
    s.y += s.z * s.x;
    s.z += s.x * s.y;
    s.w += s.y * s.z;
    s ^= s >> 16u;
    s.x += s.y * s.w;
    s.y += s.z * s.x;
    s.z += s.x * s.y;
    s.w += s.y * s.z;
    return s;
}

u32 hash(u32 s) {
    return pcg(s);
}

uvec2 hash(uvec2 s) {
    return pcg2d(s);
}

uvec3 hash(uvec3 s) {
    return pcg3d(s);
}

uvec4 hash(uvec4 s) {
    return pcg4d(s);
}

#endif

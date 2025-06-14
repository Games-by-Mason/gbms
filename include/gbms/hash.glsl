// Provides a variety of hash functions. Use the named functions when you want a specific algorithm,
// use `hash` when you just want a balanced choice for your input type.
//
// Use `floatBitsToInt` if your inputs are floats.
//
// All provided functions are on the Pareto frontier of performance and quality according to this
// paper:
//
// https://jcgt.org/published/0009/03/02/

#ifndef INCLUDE_GBMS_HASH
#define INCLUDE_GBMS_HASH

#include "constants.glsl"

// Melissa O'Neill's PCG PRNG, adapted for use as a hash function.
uint pcg(uint s) {
    uint state = s * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
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

uint hash(uint s) {
    return pcg(s);
}

uvec2 hash(uvec2 s) {
    return pcg3d(uvec3(s, 0)).xy;
}

uvec3 hash(uvec3 s) {
    return pcg3d(s);
}

uvec4 hash(uvec4 s) {
    return pcg4d(s);
}

#endif

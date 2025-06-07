#ifndef INCLUDE_GBMS_RAND
#define INCLUDE_GBMS_RAND

#include "hash.glsl"

// A reasonable default hash based random float generator that returns values between 0 and 1.
float rand(uint i) {
    return float(pcgHash(i)) / UINT_MAX;
}

float rand(uvec2 i) {
    return float(pcgHash(i)) / UINT_MAX;
}

float rand(uvec3 i) {
    return float(pcgHash(i)) / UINT_MAX;
}

float rand(uvec4 i) {
    return float(pcgHash(i)) / UINT_MAX;
}

float rand(float f) {
    return rand(uint(floatBitsToInt(f)));
}

float rand(vec2 f) {
    return rand(uvec2(floatBitsToInt(f)));
}

float rand(vec3 f) {
    return rand(uvec3(floatBitsToInt(f)));
}

float rand(vec4 f) {
    return rand(uvec4(floatBitsToInt(f)));
}

#endif

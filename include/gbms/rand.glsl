#ifndef INCLUDE_GBMS_RAND
#define INCLUDE_GBMS_RAND

#include "hash.glsl"

// A reasonable default hash based random float generator that returns values between 0 and 1.
float rand(uint seed) {
    return float(pcgHash(seed)) / UINT_MAX;
}

float rand(uvec2 seed) {
    return float(pcgHash(seed)) / UINT_MAX;
}

float rand(uvec3 seed) {
    return float(pcgHash(seed)) / UINT_MAX;
}

float rand(uvec4 seed) {
    return float(pcgHash(seed)) / UINT_MAX;
}

float rand(float seed) {
    return rand(uint(floatBitsToInt(seed)));
}

float rand(vec2 seed) {
    return rand(uvec2(floatBitsToInt(seed)));
}

float rand(vec3 seed) {
    return rand(uvec3(floatBitsToInt(seed)));
}

float rand(vec4 seed) {
    return rand(uvec4(floatBitsToInt(seed)));
}

vec2 rand2(uint seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    return vec2(x, y) / UINT_MAX;
}

vec2 rand2(uvec2 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    return vec2(x, y) / UINT_MAX;
}

vec2 rand2(uvec3 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    return vec2(x, y) / UINT_MAX;
}

vec2 rand2(uvec4 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    return vec2(x, y) / UINT_MAX;
}

vec2 rand2(float seed) {
    return rand2(uint(floatBitsToInt(seed)));
}

vec2 rand2(vec2 seed) {
    return rand2(uvec2(floatBitsToInt(seed)));
}

vec2 rand2(vec3 seed) {
    return rand2(uvec3(floatBitsToInt(seed)));
}

vec2 rand2(vec4 seed) {
    return rand2(uvec4(floatBitsToInt(seed)));
}

vec3 rand3(uint seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    return vec3(x, y, z) / UINT_MAX;
}

vec3 rand3(uvec2 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    return vec3(x, y, z) / UINT_MAX;
}

vec3 rand3(uvec3 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    return vec3(x, y, z) / UINT_MAX;
}

vec3 rand3(uvec4 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    return vec3(x, y, z) / UINT_MAX;
}

vec3 rand3(float seed) {
    return rand3(uint(floatBitsToInt(seed)));
}

vec3 rand3(vec2 seed) {
    return rand3(uvec2(floatBitsToInt(seed)));
}

vec3 rand3(vec3 seed) {
    return rand3(uvec3(floatBitsToInt(seed)));
}

vec3 rand3(vec4 seed) {
    return rand3(uvec4(floatBitsToInt(seed)));
}

vec4 rand4(uint seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    uint w = pcgHash(z);
    return vec4(x, y, z, w) / UINT_MAX;
}

vec4 rand4(uvec2 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    uint w = pcgHash(z);
    return vec4(x, y, z, w) / UINT_MAX;
}

vec4 rand4(uvec3 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    uint w = pcgHash(z);
    return vec4(x, y, z, w) / UINT_MAX;
}

vec4 rand4(uvec4 seed) {
    uint x = pcgHash(seed);
    uint y = pcgHash(x);
    uint z = pcgHash(y);
    uint w = pcgHash(z);
    return vec4(x, y, z, w) / UINT_MAX;
}

vec4 rand4(float seed) {
    return rand4(uint(floatBitsToInt(seed)));
}

vec4 rand4(vec2 seed) {
    return rand4(uvec2(floatBitsToInt(seed)));
}

vec4 rand4(vec3 seed) {
    return rand4(uvec3(floatBitsToInt(seed)));
}

vec4 rand4(vec4 seed) {
    return rand4(uvec4(floatBitsToInt(seed)));
}

#endif

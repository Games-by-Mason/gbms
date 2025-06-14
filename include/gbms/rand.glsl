// Convenience wrappers around `hash` that return random vectors or scalars between 0 and 1.

#ifndef INCLUDE_GBMS_RAND
#define INCLUDE_GBMS_RAND

#include "hash.glsl"

float rand(uint s) {
    return float(hash(s)) / UINT_MAX;
}

float rand(uvec2 s) {
    return float(hash(s)) / UINT_MAX;
}

float rand(uvec3 s) {
    return float(hash(s)) / UINT_MAX;
}

float rand(uvec4 s) {
    return float(hash(s)) / UINT_MAX;
}

float rand(float s) {
    return rand(uint(floatBitsToInt(s)));
}

float rand(vec2 s) {
    return rand(uvec2(floatBitsToInt(s)));
}

float rand(vec3 s) {
    return rand(uvec3(floatBitsToInt(s)));
}

float rand(vec4 s) {
    return rand(uvec4(floatBitsToInt(s)));
}

vec2 rand2(uint s) {
    return vec2(hash(uvec2(s, 0))) / UINT_MAX;
}

vec2 rand2(uvec2 s) {
    return vec2(hash(s)) / UINT_MAX;
}

vec2 rand2(uvec3 s) {
    return vec2(hash(s)) / UINT_MAX;
}

vec2 rand2(uvec4 s) {
    return vec2(hash(s)) / UINT_MAX;
}

vec2 rand2(float s) {
    return rand2(uint(floatBitsToInt(s)));
}

vec2 rand2(vec2 s) {
    return rand2(uvec2(floatBitsToInt(s)));
}

vec2 rand2(vec3 s) {
    return rand2(uvec3(floatBitsToInt(s)));
}

vec2 rand2(vec4 s) {
    return rand2(uvec4(floatBitsToInt(s)));
}

vec3 rand3(uint s) {
    return vec3(hash(uvec3(s, 0, 0))) / UINT_MAX;
}

vec3 rand3(uvec2 s) {
    return vec3(hash(uvec3(s, 0))) / UINT_MAX;
}

vec3 rand3(uvec3 s) {
    return vec3(hash(s)) / UINT_MAX;
}

vec3 rand3(uvec4 s) {
    return vec3(hash(s)) / UINT_MAX;
}

vec3 rand3(float s) {
    return rand3(uint(floatBitsToInt(s)));
}

vec3 rand3(vec2 s) {
    return rand3(uvec2(floatBitsToInt(s)));
}

vec3 rand3(vec3 s) {
    return rand3(uvec3(floatBitsToInt(s)));
}

vec3 rand3(vec4 s) {
    return rand3(uvec4(floatBitsToInt(s)));
}

vec4 rand4(uint s) {
    return vec4(hash(uvec4(s, 0, 0, 0))) / UINT_MAX;
}

vec4 rand4(uvec2 s) {
    return vec4(hash(uvec4(s, 0, 0))) / UINT_MAX;
}

vec4 rand4(uvec3 s) {
    return vec4(hash(uvec4(s, 0))) / UINT_MAX;
}

vec4 rand4(uvec4 s) {
    return vec4(hash(s)) / UINT_MAX;
}

vec4 rand4(float s) {
    return rand4(uint(floatBitsToInt(s)));
}

vec4 rand4(vec2 s) {
    return rand4(uvec2(floatBitsToInt(s)));
}

vec4 rand4(vec3 s) {
    return rand4(uvec3(floatBitsToInt(s)));
}

vec4 rand4(vec4 s) {
    return rand4(uvec4(floatBitsToInt(s)));
}

#endif

#ifndef INCLUDE_GBMS_RAND
#define INCLUDE_GBMS_RAND

// Convenience wrappers around `hash` that return random vectors or scalars between 0 and 1.
//
// See `hash.glsl` for more info on what algorithms are used. Note that 1 -> N hashes where N > 1
// tend not to be as high quality as N -> N or N -> 1, you should try to match the number of output
// components with inputs when possible.
//
// These functions are mirrored in `geom`:
//
// https://github.com/Games-by-Mason/geom

#include "hash.glsl"
#include "unpack.glsl"
#include "c.glsl"

f32 rand(u32 s) {
    return f32(hash(s)) * U32_MAX_RECIP;
}

f32 rand(uvec2 s) {
    return f32(hash(s)) * U32_MAX_RECIP;
}

f32 rand(uvec3 s) {
    return f32(hash(s)) * U32_MAX_RECIP;
}

f32 rand(uvec4 s) {
    return f32(hash(s)) * U32_MAX_RECIP;
}

f32 rand(f32 s) {
    return rand(u32(f32BitsToU32(s)));
}

f32 rand(vec2 s) {
    return rand(uvec2(f32BitsToU32(s)));
}

f32 rand(vec3 s) {
    return rand(uvec3(f32BitsToU32(s)));
}

f32 rand(vec4 s) {
    return rand(uvec4(f32BitsToU32(s)));
}

vec2 rand2(u32 s) {
    return vec2(hash(uvec2(s, 1))) * U32_MAX_RECIP;
}

vec2 rand2(uvec2 s) {
    return vec2(hash(s)) * U32_MAX_RECIP;
}

vec2 rand2(uvec3 s) {
    return vec2(hash(s)) * U32_MAX_RECIP;
}

vec2 rand2(uvec4 s) {
    return vec2(hash(s)) * U32_MAX_RECIP;
}

vec2 rand2(f32 s) {
    return rand2(u32(f32BitsToU32(s)));
}

vec2 rand2(vec2 s) {
    return rand2(uvec2(f32BitsToU32(s)));
}

vec2 rand2(vec3 s) {
    return rand2(uvec3(f32BitsToU32(s)));
}

vec2 rand2(vec4 s) {
    return rand2(uvec4(f32BitsToU32(s)));
}

vec3 rand3(u32 s) {
    return vec3(hash(uvec3(s, 1, 1))) * U32_MAX_RECIP;
}

vec3 rand3(uvec2 s) {
    return vec3(hash(uvec3(s, 1))) * U32_MAX_RECIP;
}

vec3 rand3(uvec3 s) {
    return vec3(hash(s)) * U32_MAX_RECIP;
}

vec3 rand3(uvec4 s) {
    return vec3(hash(s)) * U32_MAX_RECIP;
}

vec3 rand3(f32 s) {
    return rand3(u32(f32BitsToU32(s)));
}

vec3 rand3(vec2 s) {
    return rand3(uvec2(f32BitsToU32(s)));
}

vec3 rand3(vec3 s) {
    return rand3(uvec3(f32BitsToU32(s)));
}

vec3 rand3(vec4 s) {
    return rand3(uvec4(f32BitsToU32(s)));
}

vec4 rand4(u32 s) {
    return vec4(hash(uvec4(s, 1, 1, 1))) * U32_MAX_RECIP;
}

vec4 rand4(uvec2 s) {
    return vec4(hash(uvec4(s, 1, 1))) * U32_MAX_RECIP;
}

vec4 rand4(uvec3 s) {
    return vec4(hash(uvec4(s, 1))) * U32_MAX_RECIP;
}

vec4 rand4(uvec4 s) {
    return vec4(hash(s)) * U32_MAX_RECIP;
}

vec4 rand4(f32 s) {
    return rand4(u32(f32BitsToU32(s)));
}

vec4 rand4(vec2 s) {
    return rand4(uvec2(f32BitsToU32(s)));
}

vec4 rand4(vec3 s) {
    return rand4(uvec3(f32BitsToU32(s)));
}

vec4 rand4(vec4 s) {
    return rand4(uvec4(f32BitsToU32(s)));
}

#endif

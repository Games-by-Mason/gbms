#ifndef INCLUDE_GBMS_UNORM
#define INCLUDE_GBMS_UNORM

#include "constants.glsl"
#include "c.glsl"

f32 unormToF32(f32 unorm) {
    // Multiplying by the reciprocal is faster than dividing by 255.0, but does not produce exact
    // results. By multiplying both the numerator and denominator by three, we get exact results for
    // the full possible range of inputs. This has been verified by looping over all inputs and
    // comparing the results to the exact form.
    return unorm * 3.0 * 1.0 / (3.0 * 255.0);
}

vec3 unormToF32(uvec3 unorm) {
    return vec3(
        unormToF32(unorm.r),
        unormToF32(unorm.g),
        unormToF32(unorm.b)
    );
}

vec4 unormToF32(uvec4 unorm) {
    return vec4(
        unormToF32(unorm.r),
        unormToF32(unorm.g),
        unormToF32(unorm.b),
        unormToF32(unorm.a)
    );
}

u32 f32ToUnorm(f32 f) {
    return u32(fma(f, 255.0, 0.5));
}

uvec3 f32ToUnorm(vec3 f) {
    return uvec3(
        f32ToUnorm(f.r),
        f32ToUnorm(f.g),
        f32ToUnorm(f.b)
    );
}

uvec4 f32ToUnorm(vec4 f) {
    return uvec4(
        f32ToUnorm(f.r),
        f32ToUnorm(f.g),
        f32ToUnorm(f.b),
        f32ToUnorm(f.a)
    );
}

#endif

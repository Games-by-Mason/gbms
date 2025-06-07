#ifndef INCLUDE_GBMS_UNORM
#define INCLUDE_GBMS_UNORM

#include "constants.glsl"

float unormToFloat(float unorm) {
    // Multiplying by the reciprocal is faster than dividing by 255.0, but does not produce exact
    // results. By multiplying both the numerator and denominator by three, we get exact results for
    // the full possible range of inputs. This has been verified by looping over all inputs and
    // comparing the results to the exact form.
    return unorm * 3.0 * 1.0 / (3.0 * 255.0);
}

vec3 unormToFloat(uvec3 unorm) {
    return vec3(
        unormToFloat(unorm.r),
        unormToFloat(unorm.g),
        unormToFloat(unorm.b)
    );
}

vec4 unormToFloat(uvec4 unorm) {
    return vec4(
        unormToFloat(unorm.r),
        unormToFloat(unorm.g),
        unormToFloat(unorm.b),
        unormToFloat(unorm.a)
    );
}

uint floatToUnorm(float f) {
    return uint(fma(f, 255.0, 0.5));
}

uvec3 floatToUnorm(vec3 f) {
    return uvec3(
        floatToUnorm(f.r),
        floatToUnorm(f.g),
        floatToUnorm(f.b)
    );
}

uvec4 floatToUnorm(vec4 f) {
    return uvec4(
        floatToUnorm(f.r),
        floatToUnorm(f.g),
        floatToUnorm(f.b),
        floatToUnorm(f.a)
    );
}

#endif

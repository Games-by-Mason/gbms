#ifndef INCLUDE_GBMS_SRGB
#define INCLUDE_GBMS_SRGB

// These functions are mirrored in `gpu.ext`:
//
// https://github.com/Games-by-Mason/gbms

#include "constants.glsl"

float linearToSrgb(float linear) {
    // The color component transfer function from the SRGB specification:
    // https://www.w3.org/Graphics/Color/srgb
    if (linear <= 0.0031308) {
        return 12.92 * linear;
    } else {
        return fma(1.055, pow(linear, 1.0 / 2.4), -0.055);
    }
}

vec3 linearToSrgb(vec3 linear) {
    return vec3(
        linearToSrgb(linear.r),
        linearToSrgb(linear.g),
        linearToSrgb(linear.b)
    );
}

vec4 linearToSrgb(vec4 linear) {
    return vec4(
        linearToSrgb(linear.r),
        linearToSrgb(linear.g),
        linearToSrgb(linear.b),
        linear.a
    );
}


float srgbToLinear(float srgb) {
    // The inverse of the color component transfer function from the SRGB specification:
    // https://www.w3.org/Graphics/Color/srgb
    if (srgb <= 0.04045) {
        return srgb / 12.92;
    } else {
        return pow((srgb + 0.055) / 1.055, 2.4);
    }
}

vec3 srgbToLinear(vec3 srgb) {
    return vec3(
        srgbToLinear(srgb.r),
        srgbToLinear(srgb.g),
        srgbToLinear(srgb.b)
    );
}

vec4 srgbToLinear(vec4 srgb) {
    return vec4(
        srgbToLinear(srgb.r),
        srgbToLinear(srgb.g),
        srgbToLinear(srgb.b),
        srgb.a
    );
}

#endif

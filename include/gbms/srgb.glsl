#ifndef INCLUDE_GBMS_SRGB
#define INCLUDE_GBMS_SRGB

// These functions are mirrored in `gpu.ext`:
//
// https://github.com/Games-by-Mason/gbms

#include "constants.glsl"
#include "c.glsl"

f32 linearToSrgb(f32 linear) {
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


f32 srgbToLinear(f32 srgb) {
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

f32 linearToSrgbExtended(f32 linear) {
    return sign(linear) * linearToSrgb(abs(linear));
}

vec3 linearToSrgbExtended(vec3 linear) {
    return sign(linear) * linearToSrgb(abs(linear));
}

vec4 linearToSrgbExtended(vec4 linear) {
    return vec4(linearToSrgbExtended(linear.rgb), linear.a);
}

f32 srgbToLinearExtended(f32 srgb) {
    return sign(srgb) * srgbToLinear(abs(srgb));
}

vec3 srgbToLinearExtended(vec3 srgb) {
    return sign(srgb) * srgbToLinear(abs(srgb));
}

vec4 srgbToLinearExtended(vec4 srgb) {
    return vec4(srgbToLinearExtended(srgb.rgb), srgb.a);
}

#endif

#ifndef INCLUDE_GBMS_COLOR
#define INCLUDE_GBMS_COLOR

#include "constants.glsl"

float colorLinearToSrgb(float linear) {
    // The color component transfer function from the SRGB specification:
    // https://www.w3.org/Graphics/Color/srgb
    if (linear <= 0.031308) {
        return 12.92 * linear;
    } else {
        return fma(1.055, pow(linear, 1.0 / 2.4), -0.055);
    }
}

vec3 colorLinearToSrgb(vec3 linear) {
    return vec3(
        colorLinearToSrgb(linear.r),
        colorLinearToSrgb(linear.g),
        colorLinearToSrgb(linear.b)
    );
}

vec4 colorLinearToSrgb(vec4 linear) {
    return vec4(
        colorLinearToSrgb(linear.r),
        colorLinearToSrgb(linear.g),
        colorLinearToSrgb(linear.b),
        linear.a
    );
}


float colorSrgbToLinear(float srgb) {
    // The inverse of the color component transfer function from the SRGB specification:
    // https://www.w3.org/Graphics/Color/srgb
    if (srgb <= 0.04045) {
        return srgb / 12.92;
    } else {
        return pow((srgb + 0.055) / 1.055, 2.4);
    }
}

vec3 colorSrgbToLinear(vec3 srgb) {
    return vec3(
        colorSrgbToLinear(srgb.r),
        colorSrgbToLinear(srgb.g),
        colorSrgbToLinear(srgb.b)
    );
}

vec4 colorSrgbToLinear(vec4 srgb) {
    return vec4(
        colorSrgbToLinear(srgb.r),
        colorSrgbToLinear(srgb.g),
        colorSrgbToLinear(srgb.b),
        srgb.a
    );
}

float colorUnormToFloat(float unorm) {
    // Multiplying by the reciprocal is faster than dividing by 255.0, but does not produce exact
    // results. By multiplying both the numerator and denominator by three, we get exact results for
    // the full possible range of inputs. This has been verified by looping over all inputs and
    // comparing the results to the exact form.
    return unorm * 3.0 * 1.0 / (3.0 * 255.0);
}

vec3 colorUnormToFloat(uvec3 unorm) {
    return vec3(
        colorUnormToFloat(unorm.r),
        colorUnormToFloat(unorm.g),
        colorUnormToFloat(unorm.b)
    );
}

vec4 colorUnormToFloat(uvec4 unorm) {
    return vec4(
        colorUnormToFloat(unorm.r),
        colorUnormToFloat(unorm.g),
        colorUnormToFloat(unorm.b),
        colorUnormToFloat(unorm.a)
    );
}

uint colorFloatToUnorm(float f) {
    return uint(fma(f, 255.0, 0.5));
}

uvec3 colorFloatToUnorm(vec3 f) {
    return uvec3(
        colorFloatToUnorm(f.r),
        colorFloatToUnorm(f.g),
        colorFloatToUnorm(f.b)
    );
}

uvec4 colorFloatToUnorm(vec4 f) {
    return uvec4(
        colorFloatToUnorm(f.r),
        colorFloatToUnorm(f.g),
        colorFloatToUnorm(f.b),
        colorFloatToUnorm(f.a)
    );
}


// Converts linear to OkLab, a perceptual color space.
//
// Lab = (Lightness, green/red, blue/yellow)
//
// Adapted from: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
vec3 colorLinearToOklab(vec3 c)  {
    vec3 lms = c * mat3(
        vec3(0.4122214708, 0.5363325363, 0.0514459929),
        vec3(0.2119034982, 0.6806995451, 0.1073969566),
        vec3(0.0883024619, 0.2817188376, 0.6299787005)
    );

    lms = pow(lms, vec3(1.0/3.0));

    return lms * mat3(
        vec3(0.2104542553, 0.7936177850, -0.0040720468),
        vec3(1.9779984951, -2.4285922050, 0.4505937099),
        vec3(0.0259040371, 0.7827717662, - 0.8086757660)
    );
}

vec4 colorLinearToOklab(vec4 c)  {
    return vec4(colorLinearToOklab(c.rgb), c.a);
}

vec3 colorOklabToLinear(vec3 c)  {
    vec3 lms = c * mat3(
        vec3(1.0, +0.3963377774, +0.2158037573),
        vec3(1.0, -0.1055613458, -0.0638541728),
        vec3(1.0, -0.0894841775, -1.2914855480)
    );

    lms = lms * lms * lms;

    return lms * mat3(
        vec3(+4.0767416621, -3.3077115913, +0.2309699292),
        vec3(-1.2684380046, +2.6097574011, -0.3413193965),
        vec3(-0.0041960863, -0.7034186147, +1.7076147010)
    );
}

// Converts from OkLab to linear. See `colorLinearToOklab
//
// Adapted from: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
vec4 colorOklabToLinear(vec4 c)  {
    return vec4(colorOklabToLinear(c.xyz), c.w);
}
// Finds the maximum saturation possible for a given hue that fits in sRGB
// Saturation here is defined as S = C/L
// a and b must be normalized so a^2 + b^2 == 1
//
// Adapted from: https://bottosson.github.io/posts/gamutclipping/

// Returns the maximum saturation for the hue `ab` that fits in sRGB.
//
// Saturation is `C/L`, `ab` must be normalized. 
//
// Adapted from here: https://bottosson.github.io/posts/gamutclipping/#intersection-with-srgb-gamut
float colorOklabMaxSaturation(vec2 ab) {
    // Max saturation will be when one of r, g or b goes below zero.

    // Select different coefficients depending on which component goes below zero first
    float k[5];
    vec3 w_lms;

    if (dot(ab, vec2(-1.88170328, -0.80936493)) > 1) {
        k = float[5](
            +1.19086277,
            +1.76576728,
            +0.59662641,
            +0.75515197,
            +0.56771245
        );
        w_lms = vec3(4.0767416621, -3.3077115913, 0.2309699292);
    } else if (dot(ab, vec2(1.81444104, -1.19445276)) > 1) {
        k = float[5](
            +0.73956515,
            -0.45954404,
            +0.08285427,
            +0.12541070,
            +0.14503204
        );
        w_lms = vec3(-1.2684380046, 2.6097574011, -0.3413193965);
    } else {
        k = float[5](
            +1.35733652,
            -0.00915799,
            -1.15130210,
            -0.50559606,
            +0.00692167
        );
        w_lms = vec3(-0.0041960863, -0.7034186147, 1.7076147010);
    }

    float S = k[0] + k[1] * ab.x + k[2] * ab.y + k[3] * ab.x * ab.x + k[4] * ab.x * ab.y;

    vec3 k_lms = ab * mat3x2(
        vec2(+0.3963377774, +0.2158037573),
        vec2(-0.1055613458, -0.0638541728),
        vec2(-0.0894841775, -1.2914855480)
    );

    {
        vec3 lms_p1 = fma(vec3(S), k_lms, vec3(1.0));
        vec3 lms_p2 = lms_p1 * lms_p1;
        vec3 lms = lms_p2 * lms_p1;

        vec3 lms_dS = 3.0 * k_lms * lms_p2;
        vec3 lms_ds2 = 6.0 * k_lms * k_lms * lms_p1;
        vec3 f = w_lms * mat3(lms, lms_dS, lms_ds2);

        S = fma(-f.x, f.y / fma(f.y, f.y, -0.5 * f.x * f.z), S);
    }

    return S;
}

#endif

#ifndef INCLUDE_GBMS_PHYS
#define INCLUDE_GBMS_PHYS

#include "c.glsl"

// Returns the blackbody radiation color in sRGB for the given temperature in Kelvin.
//
// Adapted from https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
vec3 physBlackbodySrgb(float kelvin) {
    float t = clamp(kelvin, 1000.0, 40000.0) / 100.0;
    
    vec3 wp;
    if (t <= 66.0) {
        wp.r = 1.0;
        wp.g = clamp((99.4708025861 / 255.0) * log(t) - (161.1195681661 / 255.0), 0, 1);
    } else {
        float t = t - 60.0;
        wp.r = min((329.698727446 / 255.0) * pow(t, -0.1332047592), 1);
        wp.g = min((288.1221695283 / 255.0) * pow(t, -0.0755148492), 1);
    }
    
    if (t >= 66.0) {
        wp.b = 1.0;
    } else if (t <= 19.0) {
        wp.b = 0.0;
    } else {
        wp.b = clamp((138.5177312231 / 255.0) * log(t - 10.0) - (305.0447927307 / 255.0), 0, 1);
    }

    return wp;
}

// Returns the blackbody radiation color in linear sRGB for the given temperature in Kevlin.
vec3 physBlackbodyLinear(float kelvin) {
    return srgbToLinear(physBlackbodySrgb(kelvin));
}

#endif

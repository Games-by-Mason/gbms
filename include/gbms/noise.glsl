// Hash based noise functions.
//
// Conventions:
// * Following glsl `texture` conventions, `p` is the sample position in texture coordinates
#ifndef INCLUDE_GBMS_NOISE
#define INCLUDE_GBMS_NOISE

#include "rand.glsl"
#include "ease.glsl"

float valueNoise(float p, float tileFrequency) {
    float a = mod(floor(p), tileFrequency);
    float b = mod(a + 1.0, tileFrequency);
    float t = fract(p);
    return mix(rand(a), rand(b), smootherstep(fract(p)));
}

float valueNoise(float p) {
    return valueNoise(p, FLT_MAX);
}

float valueNoise(vec2 p, vec2 tileFrequency) {
    // Calculate the t value
    vec2 t = fract(p);

    // Get the coordinates
    vec2 c00 = mod(floor(p), tileFrequency);
    vec2 c10 = mod(c00 + vec2(1, 0), tileFrequency);
    vec2 c01 = mod(c00 + vec2(0, 1), tileFrequency);
    vec2 c11 = mod(c00 + vec2(1, 1), tileFrequency);

    // Get the samples
    float s00 = rand(c00);
    float s10 = rand(c10);
    float s01 = rand(c01);
    float s11 = rand(c11);

    // Perform bilinear interpolation with a smootherstep factor
    vec2 i0_i1 = mix(vec2(s00, s10), vec2(s01, s11), smootherstep(t.y));
    float i = mix(i0_i1.x, i0_i1.y, smootherstep(t.x));

    // Return the result;
    return i;
}

float valueNoise(vec2 p) {
    return valueNoise(p, vec2(FLT_MAX));
}

float valueNoise(vec3 p, vec3 tileFrequency) {
    // Get the t value
    vec3 t = fract(p);

    // Get the coordinates
    vec3 c000 = mod(floor(p), tileFrequency);
    vec3 c100 = mod(c000 + vec3(1, 0, 0), tileFrequency);
    vec3 c010 = mod(c000 + vec3(0, 1, 0), tileFrequency);
    vec3 c110 = mod(c000 + vec3(1, 1, 0), tileFrequency);
    vec3 c001 = mod(c000 + vec3(0, 0, 1), tileFrequency);
    vec3 c101 = mod(c000 + vec3(1, 0, 1), tileFrequency);
    vec3 c011 = mod(c000 + vec3(0, 1, 1), tileFrequency);
    vec3 c111 = mod(c000 + vec3(1, 1, 1), tileFrequency);

    // Get the samples
    float s000 = rand(c000);
    float s100 = rand(c100);
    float s010 = rand(c010);
    float s110 = rand(c110);
    float s001 = rand(c001);
    float s101 = rand(c101);
    float s011 = rand(c011);
    float s111 = rand(c111);

    // Perform trilinear interpolation with a smootherstep factor
    vec4 i00_i10_i01_i11 = mix(
        vec4(s000, s100, s010, s110),
        vec4(s001, s101, s011, s111),
        smootherstep(t.z)
    );
    vec2 i0_i1 = mix(
        vec2(i00_i10_i01_i11.xy),
        vec2(i00_i10_i01_i11.zw),
        smootherstep(t.y)
    );
    float i = mix(i0_i1.x, i0_i1.y, smootherstep(t.x));

    // Return the result;
    return i;
}

float valueNoise(vec3 p) {
    return valueNoise(p, vec3(FLT_MAX));
}

float valueNoise(vec4 p, vec4 tileFrequency) {
    // Get the t value
    vec4 t = fract(p);

    // Get the coordinates
    vec4 c0000 = mod(floor(p), tileFrequency);
    vec4 c1000 = mod(c0000 + vec4(1, 0, 0, 0), tileFrequency);
    vec4 c0100 = mod(c0000 + vec4(0, 1, 0, 0), tileFrequency);
    vec4 c1100 = mod(c0000 + vec4(1, 1, 0, 0), tileFrequency);
    vec4 c0010 = mod(c0000 + vec4(0, 0, 1, 0), tileFrequency);
    vec4 c1010 = mod(c0000 + vec4(1, 0, 1, 0), tileFrequency);
    vec4 c0110 = mod(c0000 + vec4(0, 1, 1, 0), tileFrequency);
    vec4 c1110 = mod(c0000 + vec4(1, 1, 1, 0), tileFrequency);
    vec4 c0001 = mod(c0000 + vec4(0, 0, 0, 1), tileFrequency);
    vec4 c1001 = mod(c0000 + vec4(1, 0, 0, 1), tileFrequency);
    vec4 c0101 = mod(c0000 + vec4(0, 1, 0, 1), tileFrequency);
    vec4 c1101 = mod(c0000 + vec4(1, 1, 0, 1), tileFrequency);
    vec4 c0011 = mod(c0000 + vec4(0, 0, 1, 1), tileFrequency);
    vec4 c1011 = mod(c0000 + vec4(1, 0, 1, 1), tileFrequency);
    vec4 c0111 = mod(c0000 + vec4(0, 1, 1, 1), tileFrequency);
    vec4 c1111 = mod(c0000 + vec4(1, 1, 1, 1), tileFrequency);

    // Get the samples
    float s0000 = rand(c0000);
    float s1000 = rand(c1000);
    float s0100 = rand(c0100);
    float s1100 = rand(c1100);
    float s0010 = rand(c0010);
    float s1010 = rand(c1010);
    float s0110 = rand(c0110);
    float s1110 = rand(c1110);
    float s0001 = rand(c0001);
    float s1001 = rand(c1001);
    float s0101 = rand(c0101);
    float s1101 = rand(c1101);
    float s0011 = rand(c0011);
    float s1011 = rand(c1011);
    float s0111 = rand(c0111);
    float s1111 = rand(c1111);

    // Perform quadlinear interpolation with a smootherstep factor
    vec4 i000_s100_s010_s110 = mix(
        vec4(s0000, s1000, s0100, s1100),
        vec4(s0001, s1001, s0101, s1101),
        t.w
    );
    vec4 i001_s101_s011_s111 = mix(
        vec4(s0010, s1010, s0110, s1110),
        vec4(s0011, s1011, s0111, s1111),
        t.w
    );
    vec4 i00_i10_i01_i11 = mix(
        i000_s100_s010_s110,
        i001_s101_s011_s111,
        smootherstep(t.z)
    );
    vec2 i0_i1 = mix(
        i00_i10_i01_i11.xy,
        i00_i10_i01_i11.zw,
        smootherstep(t.y)
    );
    float i = mix(i0_i1.x, i0_i1.y, smootherstep(t.x));

    // Return the result;
    return i;
}

float valueNoise(vec4 p) {
    return valueNoise(p, vec4(FLT_MAX));
}

#endif

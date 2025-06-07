#ifndef INCLUDE_GBMS_NOISE
#define INCLUDE_GBMS_NOISE

#include "rand.glsl"
#include "ease.glsl"

float valueNoise(float f) {
    float a = floor(f);
    float t = fract(f);
    return mix(rand(a), rand(a + 1.0), smootherstep(t));
}

float valueNoise(vec2 f) {
    // Get the t value
    vec2 t = fract(f);

    // Get the coordinates
    vec2 c00 = floor(f);
    vec2 c10 = c00 + vec2(1, 0);
    vec2 c01 = c00 + vec2(0, 1);
    vec2 c11 = c00 + vec2(1, 1);

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

float valueNoise(vec3 f) {
    // Get the t value
    vec3 t = fract(f);

    // Get the coordinates
    vec3 c000 = floor(f);
    vec3 c100 = c000 + vec3(1, 0, 0);
    vec3 c010 = c000 + vec3(0, 1, 0);
    vec3 c110 = c000 + vec3(1, 1, 0);
    vec3 c001 = c000 + vec3(0, 0, 1);
    vec3 c101 = c000 + vec3(1, 0, 1);
    vec3 c011 = c000 + vec3(0, 1, 1);
    vec3 c111 = c000 + vec3(1, 1, 1);

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

float valueNoise(vec4 f) {
    // Get the t value
    vec4 t = fract(f);

    // Get the coordinates
    vec4 c0000 = floor(f);
    vec4 c1000 = c0000 + vec4(1, 0, 0, 0);
    vec4 c0100 = c0000 + vec4(0, 1, 0, 0);
    vec4 c1100 = c0000 + vec4(1, 1, 0, 0);
    vec4 c0010 = c0000 + vec4(0, 0, 1, 0);
    vec4 c1010 = c0000 + vec4(1, 0, 1, 0);
    vec4 c0110 = c0000 + vec4(0, 1, 1, 0);
    vec4 c1110 = c0000 + vec4(1, 1, 1, 0);
    vec4 c0001 = c0000 + vec4(0, 0, 0, 1);
    vec4 c1001 = c0000 + vec4(1, 0, 0, 1);
    vec4 c0101 = c0000 + vec4(0, 1, 0, 1);
    vec4 c1101 = c0000 + vec4(1, 1, 0, 1);
    vec4 c0011 = c0000 + vec4(0, 0, 1, 1);
    vec4 c1011 = c0000 + vec4(1, 0, 1, 1);
    vec4 c0111 = c0000 + vec4(0, 1, 1, 1);
    vec4 c1111 = c0000 + vec4(1, 1, 1, 1);

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

#endif

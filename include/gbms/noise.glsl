// Hash based noise functions.
//
// Conventions:
// * Following glsl `texture` conventions, `p` is the sample position in texture coordinates

#ifndef INCLUDE_GBMS_NOISE
#define INCLUDE_GBMS_NOISE

#include "rand.glsl"
#include "ease.glsl"
#include "geom.glsl"

float valueNoise(float p, float period) {
    // Get the t value
    float t = fract(p);

    // Get the sample coordinates
    float c0 = mod(floor(p), period);
    float c1 = mod(c0 + 1.0, period);

    // Get the sample values
    float s0 = rand(c0);
    float s1 = rand(c1);

    // Perform linear interpolation with a smootherstep factor
    return mix(s0, s1, smootherstep(fract(p)));
}

float valueNoise(float p) {
    return valueNoise(p, FLT_MAX);
}

float valueNoise(vec2 p, vec2 period) {
    // Calculate the t value
    vec2 t = fract(p);

    // Get the sample coordinates
    vec2 c00 = mod(floor(p), period);
    vec2 c10 = mod(c00 + vec2(1, 0), period);
    vec2 c01 = mod(c00 + vec2(0, 1), period);
    vec2 c11 = mod(c00 + vec2(1, 1), period);

    // Get the samples
    float s00 = rand(c00);
    float s10 = rand(c10);
    float s01 = rand(c01);
    float s11 = rand(c11);

    // Perform bilinear interpolation with a smootherstep factor
    vec2 i0_i1 = mix(vec2(s00, s10), vec2(s01, s11), smootherstep(t.y));
    float i = mix(i0_i1.x, i0_i1.y, smootherstep(t.x));

    // Return the result
    return i;
}

float valueNoise(vec2 p) {
    return valueNoise(p, vec2(FLT_MAX));
}

float valueNoise(vec3 p, vec3 period) {
    // Get the t value
    vec3 t = fract(p);

    // Get the sample coordinates
    vec3 c000 = mod(floor(p), period);
    vec3 c100 = mod(c000 + vec3(1, 0, 0), period);
    vec3 c010 = mod(c000 + vec3(0, 1, 0), period);
    vec3 c110 = mod(c000 + vec3(1, 1, 0), period);
    vec3 c001 = mod(c000 + vec3(0, 0, 1), period);
    vec3 c101 = mod(c000 + vec3(1, 0, 1), period);
    vec3 c011 = mod(c000 + vec3(0, 1, 1), period);
    vec3 c111 = mod(c000 + vec3(1, 1, 1), period);

    // Get the sample values
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

    // Return the result
    return i;
}

float valueNoise(vec3 p) {
    return valueNoise(p, vec3(FLT_MAX));
}

float valueNoise(vec4 p, vec4 period) {
    // Get the t value
    vec4 t = fract(p);

    // Get the sample coordinates
    vec4 c0000 = mod(floor(p), period);
    vec4 c1000 = mod(c0000 + vec4(1, 0, 0, 0), period);
    vec4 c0100 = mod(c0000 + vec4(0, 1, 0, 0), period);
    vec4 c1100 = mod(c0000 + vec4(1, 1, 0, 0), period);
    vec4 c0010 = mod(c0000 + vec4(0, 0, 1, 0), period);
    vec4 c1010 = mod(c0000 + vec4(1, 0, 1, 0), period);
    vec4 c0110 = mod(c0000 + vec4(0, 1, 1, 0), period);
    vec4 c1110 = mod(c0000 + vec4(1, 1, 1, 0), period);
    vec4 c0001 = mod(c0000 + vec4(0, 0, 0, 1), period);
    vec4 c1001 = mod(c0000 + vec4(1, 0, 0, 1), period);
    vec4 c0101 = mod(c0000 + vec4(0, 1, 0, 1), period);
    vec4 c1101 = mod(c0000 + vec4(1, 1, 0, 1), period);
    vec4 c0011 = mod(c0000 + vec4(0, 0, 1, 1), period);
    vec4 c1011 = mod(c0000 + vec4(1, 0, 1, 1), period);
    vec4 c0111 = mod(c0000 + vec4(0, 1, 1, 1), period);
    vec4 c1111 = mod(c0000 + vec4(1, 1, 1, 1), period);

    // Get the sample values
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
        smootherstep(t.w)
    );
    vec4 i001_s101_s011_s111 = mix(
        vec4(s0010, s1010, s0110, s1110),
        vec4(s0011, s1011, s0111, s1111),
        smootherstep(t.w)
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

    // Return the result
    return i;
}

float valueNoise(vec4 p) {
    return valueNoise(p, vec4(FLT_MAX));
}

float _perlinGrad1(float p) {
    // Pick a random value between -1 and 1
    return mix(-1, 1, mix(-1, 1, rand(p)));
}

float perlinNoise(float p, float period) {
    // Get the cell and t value
    float cell = floor(p);
    float t = fract(p);

    // Get the sample offsets
    const float o0 = 0;
    const float o1 = 1;

    // Get the sample gradients
    float g0 = _perlinGrad1(mod(cell + o0, period));
    float g1 = _perlinGrad1(mod(cell + o1, period));

    // Get the samples
    float s0 = dot(g0, mod(t - o0, sign(0.5 - o0) * period));
    float s1 = dot(g1, mod(t - o1, sign(0.5 - o1) * period));

    // Perform linear interpolation with a smootherstep factor
    return mix(s0, s1, smootherstep(fract(p)));
}

float perlinNoise(float p) {
    return perlinNoise(p, FLT_MAX);
}

vec2 _perlinGrad2(vec2 c) {
    // Pick a random diagonal unit vector
    const vec2[8] gradients = vec2[8](
        normalize(vec2(-1, -1)),
        normalize(vec2(-1, 0)),
        normalize(vec2(-1, 1)),
        normalize(vec2(0, -1)),
        normalize(vec2(0, 1)),
        normalize(vec2(1, -1)),
        normalize(vec2(1, 0)),
        normalize(vec2(1, 1))
    );
    return gradients[hash(uvec2(floatBitsToInt(c))).x % 8];
}

float perlinNoise(vec2 p, vec2 period) {
    // Get the cell and t value
    vec2 cell = floor(p);
    vec2 t = fract(p);

    // Get the sample offsets
    const vec2 o00 = vec2(0, 0);
    const vec2 o10 = vec2(1, 0);
    const vec2 o01 = vec2(0, 1);
    const vec2 o11 = vec2(1, 1);

    // Get the sample gradients
    vec2 g00 = _perlinGrad2(mod(cell + o00, period));
    vec2 g10 = _perlinGrad2(mod(cell + o10, period));
    vec2 g01 = _perlinGrad2(mod(cell + o01, period));
    vec2 g11 = _perlinGrad2(mod(cell + o11, period));

    // Get the samples
    float s00 = dot(g00, mod(t - o00, sign(0.5 - o00) * period));
    float s10 = dot(g10, mod(t - o10, sign(0.5 - o10) * period));
    float s01 = dot(g01, mod(t - o01, sign(0.5 - o01) * period));
    float s11 = dot(g11, mod(t - o11, sign(0.5 - o11) * period));

    // Perform bilinear interpolation with a smootherstep factor
    vec2 i0_i1 = mix(vec2(s00, s10), vec2(s01, s11), smootherstep(t.y));
    float i = mix(i0_i1.x, i0_i1.y, smootherstep(t.x));

    // Return the result
    return i;
}

float perlinNoise(vec2 p) {
    return perlinNoise(p, vec2(FLT_MAX));
}

vec3 _perlinGrad3(vec3 c) {
    // Pick a random diagonal unit vector
    const vec3[12] gradients = vec3[12](
        normalize(vec3(-1, -1, 0)),
        normalize(vec3(-1, 0, -1)),
        normalize(vec3(-1, 0, 1)),
        normalize(vec3(-1, 1, 0)),
        normalize(vec3(0, -1, -1)),
        normalize(vec3(0, -1, 1)),
        normalize(vec3(0, 1, -1)),
        normalize(vec3(0, 1, 1)),
        normalize(vec3(1, -1, 0)),
        normalize(vec3(1, 0, -1)),
        normalize(vec3(1, 0, 1)),
        normalize(vec3(1, 1, 0))
    );
    return gradients[hash(uvec3(floatBitsToInt(c))).x % 12]; // Index not uniform, but close enough
}

float perlinNoise(vec3 p, vec3 period) {
    // Get the cell and t value
    vec3 cell = floor(p);
    vec3 t = fract(p);

    // Get the sample offsets
    const vec3 o000 = vec3(0, 0, 0);
    const vec3 o100 = vec3(1, 0, 0);
    const vec3 o010 = vec3(0, 1, 0);
    const vec3 o110 = vec3(1, 1, 0);
    const vec3 o001 = vec3(0, 0, 1);
    const vec3 o101 = vec3(1, 0, 1);
    const vec3 o011 = vec3(0, 1, 1);
    const vec3 o111 = vec3(1, 1, 1);

    // Get the sample gradients
    vec3 g000 = _perlinGrad3(mod(cell + o000, period));
    vec3 g100 = _perlinGrad3(mod(cell + o100, period));
    vec3 g010 = _perlinGrad3(mod(cell + o010, period));
    vec3 g110 = _perlinGrad3(mod(cell + o110, period));
    vec3 g001 = _perlinGrad3(mod(cell + o001, period));
    vec3 g101 = _perlinGrad3(mod(cell + o101, period));
    vec3 g011 = _perlinGrad3(mod(cell + o011, period));
    vec3 g111 = _perlinGrad3(mod(cell + o111, period));

    // Get the sample values
    float s000 = dot(g000, mod(t - o000, sign(0.5 - o000) * period));
    float s100 = dot(g100, mod(t - o100, sign(0.5 - o100) * period));
    float s010 = dot(g010, mod(t - o010, sign(0.5 - o010) * period));
    float s110 = dot(g110, mod(t - o110, sign(0.5 - o110) * period));
    float s001 = dot(g001, mod(t - o001, sign(0.5 - o001) * period));
    float s101 = dot(g101, mod(t - o101, sign(0.5 - o101) * period));
    float s011 = dot(g011, mod(t - o011, sign(0.5 - o011) * period));
    float s111 = dot(g111, mod(t - o111, sign(0.5 - o111) * period));

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

    // Return the result
    return i;
}

float perlinNoise(vec3 p) {
    return perlinNoise(p, vec3(FLT_MAX));
}

vec4 _perlinGrad4(vec4 c) {
    // Pick a random diagonal unit vector
    const vec4[32] gradients = vec4[32](
        normalize(vec4(-1, -1, -1, 0)),
        normalize(vec4(-1, -1, 0, -1)),
        normalize(vec4(-1, -1, 0, 1)),
        normalize(vec4(-1, -1, 1, 0)),
        normalize(vec4(-1, 0, -1, -1)),
        normalize(vec4(-1, 0, -1, 1)),
        normalize(vec4(-1, 0, 1, -1)),
        normalize(vec4(-1, 0, 1, 1)),
        normalize(vec4(-1, 1, -1, 0)),
        normalize(vec4(-1, 1, 0, -1)),
        normalize(vec4(-1, 1, 0, 1)),
        normalize(vec4(-1, 1, 1, 0)),
        normalize(vec4(0, -1, -1, -1)),
        normalize(vec4(0, -1, -1, 1)),
        normalize(vec4(0, -1, 1, -1)),
        normalize(vec4(0, -1, 1, 1)),
        normalize(vec4(0, 1, -1, -1)),
        normalize(vec4(0, 1, -1, 1)),
        normalize(vec4(0, 1, 1, -1)),
        normalize(vec4(0, 1, 1, 1)),
        normalize(vec4(1, -1, -1, 0)),
        normalize(vec4(1, -1, 0, -1)),
        normalize(vec4(1, -1, 0, 1)),
        normalize(vec4(1, -1, 1, 0)),
        normalize(vec4(1, 0, -1, -1)),
        normalize(vec4(1, 0, -1, 1)),
        normalize(vec4(1, 0, 1, -1)),
        normalize(vec4(1, 0, 1, 1)),
        normalize(vec4(1, 1, -1, 0)),
        normalize(vec4(1, 1, 0, -1)),
        normalize(vec4(1, 1, 0, 1)),
        normalize(vec4(1, 1, 1, 0))
    );
    return gradients[hash(uvec4(floatBitsToInt(c))).x % 32];
}

float perlinNoise(vec4 p, vec4 period) {
    // Get the cell and t value
    vec4 cell = floor(p);
    vec4 t = fract(p);

    // Get the sample offsets
    const vec4 o0000 = vec4(0, 0, 0, 0);
    const vec4 o1000 = vec4(1, 0, 0, 0);
    const vec4 o0100 = vec4(0, 1, 0, 0);
    const vec4 o1100 = vec4(1, 1, 0, 0);
    const vec4 o0010 = vec4(0, 0, 1, 0);
    const vec4 o1010 = vec4(1, 0, 1, 0);
    const vec4 o0110 = vec4(0, 1, 1, 0);
    const vec4 o1110 = vec4(1, 1, 1, 0);
    const vec4 o0001 = vec4(0, 0, 0, 1);
    const vec4 o1001 = vec4(1, 0, 0, 1);
    const vec4 o0101 = vec4(0, 1, 0, 1);
    const vec4 o1101 = vec4(1, 1, 0, 1);
    const vec4 o0011 = vec4(0, 0, 1, 1);
    const vec4 o1011 = vec4(1, 0, 1, 1);
    const vec4 o0111 = vec4(0, 1, 1, 1);
    const vec4 o1111 = vec4(1, 1, 1, 1);

    // Get the sample gradients
    vec4 g0000 = _perlinGrad4(mod(cell + o0000, period));
    vec4 g1000 = _perlinGrad4(mod(cell + o1000, period));
    vec4 g0100 = _perlinGrad4(mod(cell + o0100, period));
    vec4 g1100 = _perlinGrad4(mod(cell + o1100, period));
    vec4 g0010 = _perlinGrad4(mod(cell + o0010, period));
    vec4 g1010 = _perlinGrad4(mod(cell + o1010, period));
    vec4 g0110 = _perlinGrad4(mod(cell + o0110, period));
    vec4 g1110 = _perlinGrad4(mod(cell + o1110, period));
    vec4 g0001 = _perlinGrad4(mod(cell + o0001, period));
    vec4 g1001 = _perlinGrad4(mod(cell + o1001, period));
    vec4 g0101 = _perlinGrad4(mod(cell + o0101, period));
    vec4 g1101 = _perlinGrad4(mod(cell + o1101, period));
    vec4 g0011 = _perlinGrad4(mod(cell + o0011, period));
    vec4 g1011 = _perlinGrad4(mod(cell + o1011, period));
    vec4 g0111 = _perlinGrad4(mod(cell + o0111, period));
    vec4 g1111 = _perlinGrad4(mod(cell + o1111, period));

    // Get the sample values
    float s0000 = dot(g0000, mod(t - o0000, sign(0.5 - o0000) * period));
    float s1000 = dot(g1000, mod(t - o1000, sign(0.5 - o1000) * period));
    float s0100 = dot(g0100, mod(t - o0100, sign(0.5 - o0100) * period));
    float s1100 = dot(g1100, mod(t - o1100, sign(0.5 - o1100) * period));
    float s0010 = dot(g0010, mod(t - o0010, sign(0.5 - o0010) * period));
    float s1010 = dot(g1010, mod(t - o1010, sign(0.5 - o1010) * period));
    float s0110 = dot(g0110, mod(t - o0110, sign(0.5 - o0110) * period));
    float s1110 = dot(g1110, mod(t - o1110, sign(0.5 - o1110) * period));
    float s0001 = dot(g0001, mod(t - o0001, sign(0.5 - o0001) * period));
    float s1001 = dot(g1001, mod(t - o1001, sign(0.5 - o1001) * period));
    float s0101 = dot(g0101, mod(t - o0101, sign(0.5 - o0101) * period));
    float s1101 = dot(g1101, mod(t - o1101, sign(0.5 - o1101) * period));
    float s0011 = dot(g0011, mod(t - o0011, sign(0.5 - o0011) * period));
    float s1011 = dot(g1011, mod(t - o1011, sign(0.5 - o1011) * period));
    float s0111 = dot(g0111, mod(t - o0111, sign(0.5 - o0111) * period));
    float s1111 = dot(g1111, mod(t - o1111, sign(0.5 - o1111) * period));

    // Perform quadlinear interpolation with a smootherstep factor
    vec4 i000_s100_s010_s110 = mix(
        vec4(s0000, s1000, s0100, s1100),
        vec4(s0001, s1001, s0101, s1101),
        smootherstep(t.w)
    );
    vec4 i001_s101_s011_s111 = mix(
        vec4(s0010, s1010, s0110, s1110),
        vec4(s0011, s1011, s0111, s1111),
        smootherstep(t.w)
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

    // Return the result
    return i;
}

float perlinNoise(vec4 p) {
    return perlinNoise(p, vec4(FLT_MAX));
}

// Estimates the gradient for `voronoiAntialias`. This gradient isn't stable to rotation of the
// coordinate system, but it's close enough that the artifacts shouldn't be visible for the expected
// usage.
float voronoiGradient(vec2 p) {
    return compSum(fwidthCoarse(p)) / 4;
}

// Returns the blend factor to antialias 2D Vornoi noise. Other dimensions must be first projected
// onto the 2D plane being rendered, or alternatively, you may just sample them multiple times--see
// `aa.glsl` for useful antialiasing kernels.
float voronoiAntialias(vec2 p, vec2[2] points, float grad) {
    vec2 line = normalize(points[1] - points[0]);
    vec2 midpoint = mix(points[0], points[1], 0.5);
    vec2 projected = points[0] + line * dot((p - points[0]), line);
    float dist_to_midpoint = length(projected - midpoint);
    return 1.0 - clamp(remap(0, grad, 0.5, 1, dist_to_midpoint), 0.5, 1);
}

float voronoiAntialias(vec2 p, vec2[2] points) {
    return voronoiAntialias(p, points, voronoiGradient(p));
}

float voronoiAntialias(vec3 p, vec3[2] points, float grad) {
    vec3 line = normalize(points[1] - points[0]);
    vec3 midpoint = mix(points[0], points[1], 0.5);
    vec3 projected = points[0] + line * dot((p - points[0]), line);
    float dist_to_midpoint = length(projected - midpoint);
    return 1.0 - clamp(remap(0, grad, 0.5, 1, dist_to_midpoint), 0.5, 1);
}

// A one dimensional Voronoi noise sample
struct Voronoi1D {
    float point;
    uint id;
    float dist2;
};

Voronoi1D voronoiNoise(float p, float period) {
    Voronoi1D result;
    result.dist2 = FLT_MAX;
    float cell = floor(p);

    for (int offset = -1; offset <= 1; ++offset) {
        uint id = hash(floatBitsToInt(mod(cell + offset, period)));
        float point = rand(id) + offset;
        float dist2 = abs(point - fract(p));
        if (dist2 < result.dist2) {
            result.dist2 = dist2;
            result.point = cell + point;
            result.id = id;
        }
    }

    return result;
}

Voronoi1D voronoiNoise(float p) {
    return voronoiNoise(p, FLT_MAX);
}

// A one dimensional Voronoi noise sample that contains the nearest two features.
struct Voronoi1DF1F2 {
    float[2] point;
    uint[2] id;
    float[2] dist2;
};

Voronoi1DF1F2 voronoiNoiseF1F2(float p, float period) {
    Voronoi1DF1F2 result;
    for (uint i = 0; i < 2; ++i) {
        result.dist2[i] = FLT_MAX;
    }
    float cell = floor(p);

    for (int offset = -1; offset <= 1; ++offset) {
        uint id = hash(floatBitsToInt(mod(cell + offset, period)));
        float point = rand(id) + offset;
        float dist2 = abs(point - fract(p));
        for (uint i = 0; i < 2; ++i) {
            if (dist2 < result.dist2[i]) {
                if (i < 1) {
                    result.dist2[i + 1] = result.dist2[i];
                    result.point[i + 1] = result.point[i];
                    result.id[i + 1] = result.id[i];
                }
                result.dist2[i] = dist2;
                result.point[i] = cell + point;
                result.id[i] = id;
                break;
            }
        }
    }

    return result;
}

Voronoi1DF1F2 voronoiNoiseF1F2(float p) {
    return voronoiNoiseF1F2(p, FLT_MAX);
}

struct Voronoi2D {
    vec2 point;
    uint id;
    float dist2;
};

Voronoi2D voronoiNoise(vec2 p, vec2 period) {
    Voronoi2D result;
    result.dist2 = FLT_MAX;
    vec2 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            vec2 offset = vec2(x, y);
            uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
            vec2 point = rand2(id) + offset;
            float dist2 = length2(point - fract(p));
            if (dist2 < result.dist2) {
                result.dist2 = dist2;
                result.point = cell + point;
                result.id = id;
            }
        }
    }

    return result;
}

Voronoi2D voronoiNoise(vec2 p) {
    return voronoiNoise(p, vec2(FLT_MAX));
}

struct Voronoi2DF1F2 {
    vec2[2] point;
    uint[2] id;
    float[2] dist2;
};

Voronoi2DF1F2 voronoiNoiseF1F2(vec2 p, vec2 period) {
    Voronoi2DF1F2 result;
    for (uint i = 0; i < 2; ++i) {
        result.dist2[i] = FLT_MAX;
    }
    vec2 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            vec2 offset = vec2(x, y);
            uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
            vec2 point = rand2(id) + offset;
            float dist2 = length2(point - fract(p));
            for (uint i = 0; i < 2; ++i) {
                if (dist2 < result.dist2[i]) {
                    if (i < 1) {
                        result.dist2[i + 1] = result.dist2[i];
                        result.point[i + 1] = result.point[i];
                        result.id[i + 1] = result.id[i];
                    }
                    result.dist2[i] = dist2;
                    result.point[i] = cell + point;
                    result.id[i] = id;
                    break;
                }
            }
        }
    }

    return result;
}

Voronoi2DF1F2 voronoiNoiseF1F2(vec2 p) {
    return voronoiNoiseF1F2(p, vec2(FLT_MAX));
}

struct Voronoi3D {
    vec3 point;
    uint id;
    float dist2;
};

Voronoi3D voronoiNoise(vec3 p, vec3 period) {
    Voronoi3D result;
    result.dist2 = FLT_MAX;
    vec3 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            for (int z = -1; z <= 1; ++z) {
                vec3 offset = vec3(x, y, z);
                uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
                vec3 point = rand3(id) + offset;
                float dist2 = length2(point - fract(p));
                if (dist2 < result.dist2) {
                    result.dist2 = dist2;
                    result.point = cell + point;
                    result.id = id;
                }
            }
        }
    }

    return result;
}

Voronoi3D voronoiNoise(vec3 p) {
    return voronoiNoise(p, vec3(FLT_MAX));
}

struct Voronoi3DF1F2 {
    vec3[2] point;
    uint[2] id;
    float[2] dist2;
};

Voronoi3DF1F2 voronoiNoiseF1F2(vec3 p, vec3 period) {
    Voronoi3DF1F2 result;
    for (uint i = 0; i < 2; ++i) {
        result.dist2[i] = FLT_MAX;
    }
    vec3 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            for (int z = -1; z <= 1; ++z) {
                vec3 offset = vec3(x, y, z);
                uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
                vec3 point = rand3(id) + offset;
                float dist2 = length2(point - fract(p));
                for (uint i = 0; i < 2; ++i) {
                    if (dist2 < result.dist2[i]) {
                        if (i < 1) {
                            result.dist2[i + 1] = result.dist2[i];
                            result.point[i + 1] = result.point[i];
                            result.id[i + 1] = result.id[i];
                        }
                        result.dist2[i] = dist2;
                        result.point[i] = cell + point;
                        result.id[i] = id;
                        break;
                    }
                }
            }
        }
    }

    return result;
}

Voronoi3DF1F2 voronoiNoiseF1F2(vec3 p) {
    return voronoiNoiseF1F2(p, vec3(FLT_MAX));
}

struct Voronoi4D {
    vec4 point;
    uint id;
    float dist2;
};

Voronoi4D voronoiNoise(vec4 p, vec4 period) {
    Voronoi4D result;
    result.dist2 = FLT_MAX;
    vec4 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            for (int z = -1; z <= 1; ++z) {
                for (int w = -1; w <= 1; ++w) {
                    vec4 offset = vec4(x, y, z, w);
                    uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
                    vec4 point = rand4(id) + offset;
                    float dist2 = length2(point - fract(p));
                    if (dist2 < result.dist2) {
                        result.dist2 = dist2;
                        result.point = cell + point;
                        result.id = id;
                    }
                }
            }
        }
    }

    return result;
}

Voronoi4D voronoiNoise(vec4 p) {
    return voronoiNoise(p, vec4(FLT_MAX));
}

struct Voronoi4DF1F2 {
    vec4[2] point;
    uint[2] id;
    float[2] dist2;
};

Voronoi4DF1F2 voronoiNoiseF1F2(vec4 p, vec4 period) {
    Voronoi4DF1F2 result;
    for (uint i = 0; i < 2; ++i) {
        result.dist2[i] = FLT_MAX;
    }
    vec4 cell = floor(p);

    for (int x = -1; x <= 1; ++x) {
        for (int y = -1; y <= 1; ++y) {
            for (int z = -1; z <= 1; ++z) {
                for (int w = -1; w <= 1; ++w) {
                    vec4 offset = vec4(x, y, z, w);
                    uint id = hash(floatBitsToInt(mod(cell + offset, period))).x;
                    vec4 point = rand4(id) + offset;
                    float dist2 = length2(point - fract(p));
                    for (uint i = 0; i < 2; ++i) {
                        if (dist2 < result.dist2[i]) {
                            if (i < 1) {
                                result.dist2[i + 1] = result.dist2[i];
                                result.point[i + 1] = result.point[i];
                                result.id[i + 1] = result.id[i];
                            }
                            result.dist2[i] = dist2;
                            result.point[i] = cell + point;
                            result.id[i] = id;
                            break;
                        }
                    }
                }
            }
        }
    }

    return result;
}

Voronoi4DF1F2 voronoiNoiseF1F2(vec4 p) {
    return voronoiNoiseF1F2(p, vec4(FLT_MAX));
}

// In practice you likely want to just write out the FBM yourself since that's more flexible. That
// lets you rotate the coordinate system, do things besides addition, etc. However, having these
// helpers is really nice for quickly trying out ideas.
#define _GBMS_DEF_VALUE_FBM(genType) \
float valueFbm(genType p, genType period, float hurst, uint octaves, bool turbulence) { \
    float gain = exp2(-hurst); \
    float scale = 1.0; \
    float amplitude = 1.0; \
    float result = 0.0; \
    float peak = 0.0; \
    for(int i = 0; i < octaves; ++i) { \
        float octave = valueNoise(scale * p, period); \
        if (turbulence) octave = abs(mix(-1, 1, octave)); \
        result += amplitude * octave; \
        peak += amplitude; \
        scale *= 2.0; \
        amplitude *= gain; \
    } \
    return result / peak; \
} \
float valueFbm(genType p, float hurst, uint octaves, bool turbulence) { \
    return valueFbm(p, genType(FLT_MAX), hurst, octaves, turbulence); \
}

_GBMS_DEF_VALUE_FBM(float)
_GBMS_DEF_VALUE_FBM(vec2)
_GBMS_DEF_VALUE_FBM(vec3)
_GBMS_DEF_VALUE_FBM(vec4)

#undef _GBMS_DEF_VALUE_FBM

#define _GBMS_DEF_PERLIN_FBM(genType) \
float perlinFbm(genType p, genType period, float hurst, uint octaves, bool turbulence) { \
    float gain = exp2(-hurst); \
    float scale = 1.0; \
    float amplitude = 1.0; \
    float result = 0.0; \
    for(int i = 0; i < octaves; ++i) { \
        float octave = perlinNoise(scale * p, period); \
        if (turbulence) octave = abs(octave); \
        result += amplitude * octave; \
        scale *= 2.0; \
        amplitude *= gain; \
    } \
    return result; \
} \
float perlinFbm(genType p, float hurst, uint octaves, bool turbulence) { \
    return perlinFbm(p, genType(FLT_MAX), hurst, octaves, turbulence); \
}

_GBMS_DEF_PERLIN_FBM(float)
_GBMS_DEF_PERLIN_FBM(vec2)
_GBMS_DEF_PERLIN_FBM(vec3)
_GBMS_DEF_PERLIN_FBM(vec4)

#undef _GBMS_DEF_PERLIN_FBM

#define _GBMS_DEF_VORONOI_FBM(genType) \
float voronoiFbm(genType p, genType period, float hurst, uint octaves, bool turbulence) { \
    float gain = exp2(-hurst); \
    float scale = 1.0; \
    float amplitude = 1.0; \
    float result = 0.0; \
    float peak = 0.0; \
    for(int i = 0; i < octaves; ++i) { \
        float octave = sqrt(voronoiNoise(scale * p, period).dist2); \
        if (turbulence) octave = abs(mix(-1, 1, octave)); \
        result += amplitude * octave; \
        peak += amplitude; \
        scale *= 2.0; \
        amplitude *= gain; \
    } \
    return result / peak; \
} \
float voronoiFbm(genType p, float hurst, uint octaves, bool turbulence) { \
    return voronoiFbm(p, genType(FLT_MAX), hurst, octaves, turbulence); \
}

_GBMS_DEF_VORONOI_FBM(float)
_GBMS_DEF_VORONOI_FBM(vec2)
_GBMS_DEF_VORONOI_FBM(vec3)
_GBMS_DEF_VORONOI_FBM(vec4)

#undef _GBMS_DEF_VALUE_FBM

#endif

#ifndef INCLUDE_GBMS_HDR10
#define INCLUDE_GBMS_HDR10

#include "c.glsl"

// Conversions from linear light to HDR10. Checked visually, not yet thoroughly verified or compared
// to spec.
//
// References:
// - https://github.com/microsoft/Xbox-ATG-Samples/blob/main/Kits/ATGTK/HDR/HDRCommon.hlsli
// - https://panoskarabelas.com/blog/posts/hdr_in_under_10_minutes/
//
// If your values exceed `st2084_max_nits`, you'll need to tone map or gamut clip. If you want to
// output an HDR signal to an SDR monitor, you'll need to tone map.
//
// No functionality is currently provided for this. This functionality can still be useful without
// tone mapping or gamut clipping in simple cases, such as rendering SDR art with keyed out sections
// boosted when HDR is enabled.

const f32 st2084_max_nits = 10000.0;

const mat3x3 rec709ToRec2020 = mat3x3(
    0.6274040, 0.3292820, 0.0433136,
    0.0690970, 0.9195400, 0.0113612,
    0.0163916, 0.0880132, 0.8955950
);

vec3 linearToSt2084(vec3 normalizedLinear) {
    const f32 m1 = (2610.0 / 4096.0) / 4.0;
    const f32 m2 = (2523.0 / 4096.0) * 128.0;

    const f32 c1 = (3424.0 / 4096.0);
    const f32 c2 = (2413.0 / 4096.0) * 32.0;
    const f32 c3 = (2392.0 / 4096.0) * 32.0;

    vec3 cp = pow(abs(normalizedLinear), vec3(m1));
    normalizedLinear = pow(
        fma(cp, vec3(c2), vec3(c1)) / fma(vec3(c3), cp, vec3(1.0)),
        vec3(m2)
    );
    return normalizedLinear;
}

// According to Microsoft, while the SDR spec says paper white should be 80 nits, the spec assumed a
// dark environemnt, and in practice you need to go much higher. They say that SDR PC monitors range
// from 200-300 nits, other sources recommend values as high as 350 nits. Ultimately the correct
// answer is dependent on the viewing conditions.
vec3 linearToSt2084Normalized(vec3 linear, f32 paper_white_nits) {
    return linear * paper_white_nits / st2084_max_nits;
}

vec3 linearToHdr10(vec3 color, f32 paper_white_nits) {
    color = color * rec709ToRec2020;
    color = linearToSt2084Normalized(color, paper_white_nits);
    color = linearToSt2084(color);
    return color;
}

vec4 linearToHdr10(vec4 color, f32 paper_white_nits) {
    return vec4(linearToHdr10(color.rgb, paper_white_nits), color.a);
}

#endif

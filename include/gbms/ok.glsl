#ifndef INCLUDE_GBMS_OK
#define INCLUDE_GBMS_OK

#include "constants.glsl"

// Converts linear to OkLab, a perceptual color space.
//
// Lab = (Lightness, green/red, blue/yellow)
//
// Adapted from: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
vec3 linearToOklab(vec3 linear)  {
    vec3 lms = linear * mat3(
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

vec4 linearToOklab(vec4 linear)  {
    return vec4(linearToOklab(linear.rgb), linear.a);
}

// Converts from OkLab to linear. See `linearToOklab`.
//
// Adapted from: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
vec3 oklabToLinear(vec3 lab)  {
    vec3 lms = lab * mat3(
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

vec4 oklabToLinear(vec4 lab)  {
    return vec4(oklabToLinear(lab.xyz), lab.w);
}

// Returns the maximum saturation for the hue `ab` that fits in sRGB.
//
// Saturation is `C/L`, `ab` must be normalized. 
//
// Adapted from here: https://bottosson.github.io/posts/gamutclipping/#intersection-with-srgb-gamut
float oklabMaxSaturation(vec2 ab) {
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

// Finds L and C cusp for an Oklab hue. `ab` must be normalized.
//
// Adapted from: https://bottosson.github.io/posts/gamutclipping/#intersection-with-srgb-gamut
vec2 _oklabFindCusp(vec2 ab) {
    float S_cusp = oklabMaxSaturation(ab);
    vec3 rgb_at_max = oklabToLinear(vec3(1, S_cusp * ab));
    float L_cusp = pow(1.0 / max(max(rgb_at_max.r, rgb_at_max.g), rgb_at_max.b), 1.0 / 3.0);
    float C_cusp = L_cusp * S_cusp;
    return vec2(L_cusp , C_cusp);
}

// Toe function for `L_r`.
// 
// Adapted from: https://bottosson.github.io/posts/colorpicker/#common-code
float _oklabToe(float x) {
    vec3 k;
    k.x = 0.206;
    k.y = 0.03;
    k.z = (1.0 + k.x) / (1.0 + k.y);
    float kzx = k.z * x;
    float term = kzx - k.x;
    return 0.5 * (term + sqrt(fma(term, term, 4.0 * k.y * kzx)));
}

// Inverse toe function for `L_r`.
//
// Adapted from: https://bottosson.github.io/posts/colorpicker/#common-code
float _oklabToeInv(float x) {
    vec3 k;
    k.x = 0.206;
    k.y = 0.03;
    k.z = (1.0 + k.x) / (1.0 + k.y);
    return fma(x, x, k.x * x) / (k.z * (x + k.y));
}

// Adapted from: https://bottosson.github.io/posts/colorpicker/#common-code
vec2 _oklabToSt(vec2 cusp) {
    return vec2(cusp.y / cusp.x, cusp.y / (1 - cusp.x));
}

// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsl-2
vec2 _colorGetStMid(vec2 ab) {
    return vec2(0.11516993, 0.11239642) + 1.0 / (vec2(+7.44778970, +1.61320320)
        + fma(vec2(4.15901240, -0.68124379), vec2(ab.y), ab.x * (vec2(-2.19557347, +0.40370612)
            + fma(vec2(1.75198401, 0.90148123), vec2(ab.y), ab.x * (vec2(-2.13704948, -0.27087943)
                + fma(vec2(-10.02301043, 0.61223990), vec2(ab.y), ab.x * (vec2(-4.24894561, +0.00299215)
                    + fma(vec2(5.38770819, -0.45399568), vec2(ab.y), vec2(4.69891013, -0.14661872) * ab.x))))))));
}

// Adapted from: https://bottosson.github.io/posts/gamutclipping/#intersection-with-srgb-gamut
float _oklabFindGamutIntersection(float a, float b, float L1, float C1, float L0, vec2 cusp) {
    // Find the intersection for upper and lower half separately
    if ((L1 - L0) * cusp.y - (cusp.x - L0) * C1 <= 0.0) {
        return cusp.y * L0 / (C1 * cusp.x + cusp.y * (L0 - L1));
    } else {
        float t = cusp.y * (L0 - 1.0) / (C1 * (cusp.x - 1.0) + cusp.y * (L0 - L1));

        float dL = L1 - L0;
        float dC = C1;

        vec3 k_lms = a * vec3(+0.3963377774, -0.1055613458, -0.0894841775)
            + b * vec3(0.2158037573, -0.0638541728, -1.2914855480);

        vec3 lms_dt = dL + dC * k_lms;

        float L = L0 * (1.0 - t) + t * L1;
        float C = t * C1;

        vec3 lms1 = L + C * k_lms;
        vec3 lms2 = lms1 * lms1;
        vec3 lms = lms2 * lms1;

        vec3 lmsdt = 3 * lms_dt * lms2;
        vec3 lmsdt2 = 6 * lms_dt * lms_dt * lms1;

        vec3 t_rgb;
        vec3 u_rgb;

        vec3 r = 4.0767416621 * vec3(lms.x, lmsdt.x, lmsdt2.x)
            - 3.3077115913 * vec3(lms.y, lmsdt.y, lmsdt2.x)
            + 0.2309699292 * vec3(lms.z, lmsdt.z, lmsdt2.z)
            + vec3(-1, 0, 0);
        u_rgb.r = r.y / (r.y * r.y - 0.5 * r.x * r.z);
        t_rgb.r = -r.x * u_rgb.r;

        vec3 g = -1.2684380046 * vec3(lms.x, lmsdt.x, lmsdt2.x)
            + 2.6097574011 * vec3(lms.y, lmsdt.y, lmsdt2.x)
            - 0.3413193965 * vec3(lms.z, lmsdt.z, lmsdt2.z)
            + vec3(-1, 0, 0);
        u_rgb.g = g.y / (g.y * g.y - 0.5 * g.x * g.z);
        t_rgb.g = -g.x * u_rgb.g;

        vec3 b = -0.0041960863 * vec3(lms.x, lmsdt.x, lmsdt2.x)
            - 0.7034186147 * vec3(lms.y, lmsdt.y, lmsdt2.x)
            + 1.7076147010 * vec3(lms.z, lmsdt.z, lmsdt2.z)
            + vec3(-1, 0, 0);

        u_rgb.b = b.y / (b.y * b.y - 0.5 * b.x * b.z);
        t_rgb.b = -b.x * u_rgb.b;

        t_rgb = mix(vec3(FLT_MAX), t_rgb, step(0.0, u_rgb));
        t += min(t_rgb.r, min(t_rgb.g, t_rgb.b));

        return t;
    }
}

float _oklabFindGamutIntersection(float a, float b, float L1, float C1, float L0) {
    return _oklabFindGamutIntersection(a, b, L1, C1, L0, _oklabFindCusp(vec2(a, b)));
}

// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsl-2
void _oklabGetCs(vec3 Lab, out float C_0, out float C_mid, out float C_max) {
    vec2 cusp = _oklabFindCusp(Lab.yz);

    C_max = _oklabFindGamutIntersection(Lab.y, Lab.z, Lab.x, 1.0, Lab.x, cusp);

    vec2 ST_max = _oklabToSt(cusp);    
    vec2 L_L_inv = vec2(Lab.x, 1.0 - Lab.x);
    vec2 k_mins = L_L_inv * ST_max;
    float k = C_max / min(k_mins.x, k_mins.y);

    {
        vec2 ST_mid = _colorGetStMid(Lab.yz);
        vec2 C_ab = L_L_inv * ST_mid;
        vec2 C_ab2 = C_ab * C_ab;
        vec2 C_ab4 = C_ab2 * C_ab2;
        vec2 C_ab4_inv = 1.0 / C_ab4;
        C_mid = 0.9 * k * sqrt(sqrt(1.0 / (C_ab4_inv.x + C_ab4_inv.y)));
    }

    {
        vec2 C_ab = L_L_inv * vec2(0.4, 0.8);
        vec2 C_ab2 = C_ab * C_ab;
        vec2 C_ab2_inv = 1.0 / C_ab2;
        C_0 = sqrt(1.0 / (C_ab2_inv.x + C_ab2_inv.y));
    }
}


// Converts Okhsv to Oklab. Okhsv is a better hue/saturation/value style color space.
//
// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsv-2
vec3 okhsvToOklab(vec3 hsv) {
    vec2 ab = vec2(cos(2.0 * PI * hsv.x), sin(2.0 * PI * hsv.x));
    
    vec2 cusp = _oklabFindCusp(ab);
    vec2 ST_max = _oklabToSt(cusp);
    float S_0 = 0.5;
    float k = 1.0 - S_0 / ST_max.x;

    float denominator = fma(-ST_max.y, k * hsv.y, S_0 + ST_max.y);
    vec2 LC_v = hsv.y * vec2(S_0, ST_max.y * S_0) / denominator;
    LC_v.x = 1.0 - LC_v.x;

    vec2 LC = hsv.z * LC_v;

    // then we compensate for both toe and the curved top part of the triangle:
    float L_vt = _oklabToeInv(LC_v.x);
    float C_vt = LC_v.y * L_vt / LC_v.x;

    float L_new = _oklabToeInv(LC.x);
    LC.y = LC.y * L_new / LC.x;
    LC.x = L_new;

    vec3 rgb_scale = oklabToLinear(vec3(L_vt, ab * vec2(C_vt)));
    float scale_L = pow(1.0 / max(max(rgb_scale.r, rgb_scale.g), max(rgb_scale.b, 0.0)), 1.0 / 3.0);
    LC *= scale_L;

    return vec3(LC.x, LC.y * ab);
}

vec4 okhsvToOklab(vec4 hsv) {
    return vec4(okhsvToOklab(hsv.xyz), hsv.w);
}

vec3 okhsvToLinear(vec3 hsv) {
    return oklabToLinear(okhsvToOklab(hsv));
}

vec4 okhsvToLinear(vec4 hsv) {
    return vec4(okhsvToLinear(hsv.xyz), hsv.w);
}

// Converts Oklab to Okhsv. See `okhsvToOklab`.
//
// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsv-2
vec3 oklabToOkhsv(vec3 lab) {
    vec2 LC = vec2(lab.x, length(lab.yz));
    float h = 0.5 + 0.5 * atan(-lab.z, -lab.y) / PI;
    vec2 ab_ = lab.yz / LC.y;

    vec2 cusp = _oklabFindCusp(ab_);
    vec2 ST_max = _oklabToSt(cusp);
    float S_0 = 0.5;
    float k = 1.0 - S_0 / ST_max.x;

    float t = ST_max.y / (LC.y + LC.x * ST_max.y);
    vec2 LC_v = t * LC;

    vec2 LC_vt;
    LC_vt.x = _oklabToeInv(LC_v.x);
    LC_vt.y = LC_v.y * LC_vt.x / LC_v.x;

    vec3 rgb_scale = oklabToLinear(vec3(LC_vt.x, ab_ * LC_vt.y));
    float scale_L = pow(1.0 / max(max(rgb_scale.r, rgb_scale.g), max(rgb_scale.b, 0.0)), 1.0 / 3.0);
    LC /= scale_L;

    float toe = _oklabToe(LC.x);
    LC.y = LC.y * toe / LC.x;
    LC.x = toe;

    float v = LC.x / LC_v.x;
    float s = (S_0 + ST_max.y) * LC_v.y / fma(ST_max.y, S_0, ST_max.y * k * LC_v.y);

    return vec3(h, s, v);
}

vec4 oklabToOkhsv(vec4 lab) {
    return vec4(oklabToOkhsv(lab.xyz), lab.w);
}

vec3 linearToOkHsv(vec3 linear) {
    return oklabToOkhsv(linearToOklab(linear));
}

vec4 linearToOkHsv(vec4 linear) {
    return vec4(oklabToOkhsv(linearToOklab(linear.rgb)), linear.a);
}

// Converts Okhsl to Oklab. Okhsl is a better hue/saturation/lightness style color space.
//
// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsl-2
vec3 okhslToOklab(vec3 hsl) {
    if (hsl.z == 1.0) return vec3(1.0, 0.0, 0.0); // White
    if (hsl.z == 0.0) return vec3(0.0); // Black

    float r = 2.0 * PI * hsl.x;
    vec3 Lab = vec3(_oklabToeInv(hsl.z), cos(r), sin(r));

    float C_0;
    float C_mid;
    float C_max;
    _oklabGetCs(Lab, C_0, C_mid, C_max);

    float mid = 0.8;
    float mid_inv = 1.25;

    float C;
    if (hsl.y < mid) {
        float t = mid_inv * hsl.y;
        float k_1 = mid * C_0;
        float k_2 = (1.0 - k_1 / C_mid);
        C = t * k_1 / (1.0 - k_2 * t);
    } else {
        // This simplification affects the end result slightly, but Björn's Javascript color picker
        // makes the same optimization
        float t = 5 * (hsl.y - mid);

        float k_0 = C_mid;
        float k_1 = (1.0 - mid) * C_mid * C_mid * mid_inv * mid_inv / C_0;
        float k_2 = (1.0 - k_1 / (C_max - C_mid));
        C = k_0 + t * k_1 / (1.0 - k_2 * t);
    }

    return vec3(Lab.x, Lab.yz * C);
}

vec4 okhslToOklab(vec4 hsl) {
    return vec4(okhslToOklab(hsl.xyz), hsl.w);
}

vec3 okhslToLinear(vec3 hsl) {
    return oklabToLinear(okhslToOklab(hsl));
}

vec4 okhslToLinear(vec4 hsl) {
    return vec4(okhslToLinear(hsl.xyz), hsl.w);
}

// Converts Oklab to Okhsl. See `okhslToOklab`.
//
// Adapted from: https://bottosson.github.io/posts/colorpicker/#hsl-2
vec3 oklabToOkhsl(vec3 lab) {
    float C = sqrt(lab.y * lab.y + lab.z * lab.z);
    vec3 Lab_ = vec3(lab.x, lab.yz / C);

    float h = 0.5 + 0.5 * atan(-lab.z, -lab.y) / PI;

    float C_0;
    float C_mid;
    float C_max;
    _oklabGetCs(Lab_, C_0, C_mid, C_max);

    float mid = 0.8;
    float mid_inv = 1.25;

    float s;
    if (C < C_mid) {
        float k_1 = mid * C_0;
        float k_2 = (1.0 - k_1 / C_mid);

        float t = C / (k_1 + k_2 * C);
        s = t * mid;
    } else {
        float k_0 = C_mid;
        float k_1 = (1.0 - mid) * C_mid * C_mid * mid_inv * mid_inv / C_0;
        float k_2 = (1.0 - (k_1) / (C_max - C_mid));

        float t = (C - k_0) / (k_1 + k_2 * (C - k_0));
        s = mid + (1.0 - mid) * t;
    }

    float l = _oklabToe(Lab_.x);

    return vec3(h, s, l);
}

vec4 oklabToOkhsl(vec4 lab) {
    return vec4(oklabToOkhsl(lab.xyz), lab.w);
}

vec3 colorLinearToOkhsl(vec3 linear) {
    return oklabToOkhsl(linearToOklab(linear));
}

vec4 colorLinearToOkhsl(vec4 linear) {
    return oklabToOkhsl(linearToOklab(linear));
}

#endif

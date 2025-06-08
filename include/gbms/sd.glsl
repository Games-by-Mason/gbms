// Signed distance field functions, mostly adapted from Inigo Quilez's work:
//
// https://iquilezles.org/articles/distfunctions2d/
//
// Conventions:
// * Following glsl `texture` conventions, `p` is the sample position in texture coordinates
// * Texture coordinates are used units wherever it makes sense
// * Functions that take a `round` argument have rounded corners, the corners are specified clockwise
//   starting from the top left most corner
// * Unless otherwise specified, shapes are centered around
//   the origin.
// * `a` and `b` are start and endpoints
// * For regular polygons, the radius is the radius of the circle contained by the polygon. For star
//   like shapes that are inset from regular polygons, the radius is the radius of the circle that
//   contains the shape. This may be revisited.
// * Operations that combine SDFs (e.g. those based on min and max) are approximate, and may not result
//   in 100% valid SDFs
//
// Tips:
// * Use `sdDebug`
// * Animate parameters to quickly explore the state space
// * These are starting points. If performance is critical, it's likely possible to optimize these
//   functions for the constants you're using them with.
// * You can mirror a SDF by taking the absolute value of sample coordinate, you can repeat an SDF
//   by tiling the sample coordinates
//
// Note also that there are many other smooth minimum alternatives not implemented here you may want
// to play with depending on your needs. Here's a good write up:
//
// https://iquilezles.org/articles/smin/

#ifndef INCLUDE_GBMS_SDF
#define INCLUDE_GBMS_SDF

#include "srgb.glsl"
#include "geom.glsl"

// Returns the approximate gradient of the SDF for antialiasing. This could be calculated more
// precisely by taking length of vec2(dx, dy), but the difference isn't visually perceptible for the
// purposes of antialiasing.
float sdGradient(float sdf) {
    return fwidth(sdf);
}

// Similar to `sdSample`, but does not convert to linear space. This is faster than `sdSample` but
// produces  visibly worse antialiasing.
float sdSampleSrgb(float sdf, float gradient) {
    float threshold2 = gradient * 0.5;
    return ilerp(-threshold2, threshold2, sdf);
}

// Similar to `sdSample`, but does not convert to linear space. This is faster than `sdSample` but
// produces  visibly worse antialiasing.
float sdSampleSrgb(float sdf) {
    return sdSampleSrgb(sdf, fwidth(sdf));
}

// Samples a SDF.
float sdSample(float sdf, float gradient) {
    return srgbToLinear(sdSampleSrgb(sdf, gradient));
}

// Samples a SDF.
float sdSample(float sdf) {
    return srgbToLinear(sdSampleSrgb(sdf, fwidth(sdf)));
}

// Debug output for an SDF.
vec4 sdDebug(float sdf, float scale) {
    vec3 col = (sdf > 0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
    col *= 1.0 - exp(-6.0 * abs(sdf * scale));
    col *= 0.8 + 0.2 * cos(150.0 * sdf * scale);
    col = mix( col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, abs(sdf * scale)) );
    return srgbToLinear(vec4(col,1.0));
}

// Debug output for an SDF.
vec4 sdDebug(float sdf) {
    return sdDebug(sdf, 1.0);
}

float sdCircle(vec2 p, float radius) {
    return length(p) - radius;
}

float sdBox(vec2 p, vec2 size) {
    vec2 d = abs(p) - size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdRoundedBox(vec2 p, vec2 size, vec4 round) {
    round.zy = (p.x > 0.0) ? round.zy : round.wx;
    round.z = (p.y > 0.0) ? round.z : round.y;
    vec2 q = abs(p) - size + round.z;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - round.z;
}

float sdChamferBox(vec2 p, vec2 size, float chamfer) {
    p = abs(p) - size;

    p = (p.y > p.x) ? p.yx : p.xy;
    p.y += chamfer;
    
    const float k = 1.0 - sqrt(2.0);
    if (p.y < 0.0 && p.y + p.x * k < 0.0) return p.x;
    
    if (p.x < p.y) return (p.x + p.y) * sqrt(0.5);
    
    return length(p);
}

float sdOrientedBox(vec2 p, vec2 a, vec2 b, float width) {
    float l = length(b - a);
    vec2 d = (b - a) / l;
    vec2 q = (p - (a + b) * 0.5);
    q = mat2(d.x, -d.y, d.y, d.x) * q;
    q = abs(q) - vec2(l, width) * 0.5;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / length2(ba), 0.0, 1.0);
    return length(pa - ba * h);
}

float _sdNDot(vec2 a, vec2 b) {
    return a.x * b.x - a.y * b.y;
}

float sdRhombus(vec2 p, vec2 size)  {
    p = abs(p);
    float h = clamp(_sdNDot(size - 2.0 * p, size) / length2(size), -1.0, 1.0);
    float d = length(p - 0.5 * size * vec2(1.0 - h,1.0 + h));
    return d * sign(p.x * size.y + p.y * size.x - size.x * size.y);
}

float sdTrapezoid(vec2 p, float topHalfWidth, float bottomHalfWidth, float height) {
    vec2 k1 = vec2(bottomHalfWidth, height);
    vec2 k2 = vec2(bottomHalfWidth - topHalfWidth, 2.0 * height);
    p.x = abs(p.x);
    vec2 ca = vec2(p.x - min(p.x, (p.y < 0.0) ? topHalfWidth : bottomHalfWidth), abs(p.y) - height);
    vec2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / length2(k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(length2(ca), length2(cb)));
}

float sdParallelogram(vec2 p, float halfWidth, float halfHeight, float skew) {
    vec2 e = vec2(skew, halfHeight);
    p = (p.y < 0.0) ? - p : p;

    vec2  w = p - e;
    w.x -= clamp(w.x, -halfWidth, halfWidth);

    vec2  d = vec2(length2(w), -w.y);
    float s = p.x * e.y - p.y * e.x;
    p = (s < 0.0) ? -p : p;
    
    vec2  v = p - vec2(halfWidth, 0);
    v -= e * clamp(dot(v, e) / length2(e), -1.0, 1.0);
    
    d = min(d, vec2(length2(v), halfWidth * halfHeight - abs(s)));
    return sqrt(d.x) * sign(-d.y);
}

float sdEquilateralTriangle(vec2 p, float halfWidth) {
    const float k = sqrt(3.0);
    p.x = abs(p.x) - halfWidth;
    p.y = p.y + halfWidth/k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * halfWidth, 0.0);
    return -length(p) * sign(p.y);
}

// Origin at the top of the triangle.
float sdIsocolesTriangle(vec2 p, vec2 halfSize) {
    p.x = abs(p.x);
    vec2 a = p - halfSize * clamp(dot(p, halfSize) / length2(halfSize), 0.0, 1.0);
    vec2 b = p - halfSize * vec2(clamp(p.x / halfSize.x, 0.0, 1.0), 1.0);
    float s = -sign(halfSize.y);
    vec2 d = min(vec2(length2(a), s * outerProd(p, halfSize)), vec2(length2(b), s * (p.y - halfSize.y)));
    return -sqrt(d.x) * sign(d.y);
}

float sdTriangle(vec2 p, vec2 p0, vec2 p1, vec2 p2) {
    vec2 e0 = p1 - p0;
    vec2 e1 = p2 - p1;
    vec2 e2 = p0 - p2;

    vec2 v0 = p - p0;
    vec2 v1 = p - p1;
    vec2 v2 = p - p2;

    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / length2(e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / length2(e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / length2(e2), 0.0, 1.0);

    float s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(
        vec2(length2(pq0), s * outerProd(v0, e0)),
        vec2(length2(pq1), s * outerProd(v1, e1))),
        vec2(length2(pq2), s * outerProd(v2, e2)));

    return -sqrt(d.x) * sign(d.y);
}

float sdUnevenCapsule(vec2 p, float topRadius, float bottomRadius, float height) {
    p.x = abs(p.x);
    float b = (topRadius - bottomRadius) / height;
    float a = sqrt(1.0 - b * b);
    float k = dot(p, vec2(-b, a));
    if (k < 0.0) return length(p) - topRadius;
    if (k > a * height) return length(p - vec2(0.0, height)) - bottomRadius;
    return dot(p, vec2(a, b)) - topRadius;
}

float sdPentagon(vec2 p, float radius) {
    const vec3 k = vec3(0.809016994, 0.587785252, 0.726542528);
    p.x = abs(p.x);
    p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * vec2(k.x, k.y);
    p -= vec2(clamp(p.x, -radius * k.z, radius * k.z), radius);    
    return length(p) * sign(p.y);
}

float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

float sdOctogon(vec2 p, float r) {
    const vec3 k = vec3(-0.9238795325, 0.3826834323, 0.4142135623);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x,k.y);
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

float sdHexagram(vec2 p, float r) {
    const vec4 k = vec4(-0.5, 0.8660254038, 0.5773502692, 1.7320508076);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= 2.0 * min(dot(k.yx, p), 0.0) * k.yx;
    p -= vec2(clamp(p.x, r * k.z, r * k.w), r);
    return length(p) * sign(p.y);
}

float sdPentagram(vec2 p, float r) {
    const float k1x = 0.809016994;
    const float k2x = 0.309016994;
    const float k1y = 0.587785252;
    const float k2y = 0.951056516;
    const float k1z = 0.726542528;

    const vec2 v1  = vec2(k1x, -k1y);
    const vec2 v2  = vec2(-k1x, -k1y);
    const vec2 v3  = vec2(k2x, -k2y);
    
    p.x = abs(p.x);
    p -= 2.0 * max(dot(v1, p), 0.0) * v1;
    p -= 2.0 * max(dot(v2, p), 0.0) * v2;
    p.x = abs(p.x);
    p.y -= r;
    return length(p - v3 * clamp(dot(p, v3), 0.0, k1z * r)) * sign(outerProd(v3, p));
}

float sdStar(vec2 p, float radius, int points, float innerRadiusRatio) {
    float m = mix(points, 2.0, innerRadiusRatio);
    float an = PI / float(points);
    float en = PI / m;
    vec2  acs = vec2(cos(an), sin(an));
    vec2  ecs = vec2(cos(en), sin(en));

    float bn = mod(atan(p.x, p.y), 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= radius * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, radius * acs.y / ecs.y);
    return length(p) * sign(p.x);
}

float sdPie(vec2 p, vec2 rotor, float radius) {
    rotor = rotorInverse(rotor);
    p.x = abs(p.x);
    float l = length(p) - radius;
    float m = length(p - rotor * clamp(dot(p, rotor), 0.0, radius));
    return max(l, m * sign(outerProd(p, rotor)));
}

// `cut` ranges from [-0.5, 0.5].
float sdCutDisk(vec2 p, float radius, float cut) {
    float w = sqrt(radius * radius - cut * cut);
    p.x = abs(p.x);
    float s = max((cut - radius) * p.x * p.x + w * w * (cut + radius - 2.0 * p.y), cut * p.x - w * p.y);
    if (s < 0.0) {
        return length(p) - radius;
    } else if (p.x < w) {
        return cut - p.y;
    } else {
        return length(p - vec2(w, cut));
    }
}

float sdArc(vec2 p, vec2 rotor, float curveRadius, float pathRadius) {
    p.x = abs(p.x);
    if (rotor.y * p.x > -rotor.x * p.y) {
        return length(p - rotorInverse(rotor) * curveRadius) - pathRadius;
    } else {
        return abs(length(p) - curveRadius) - pathRadius;
    }
}

float sdRing(vec2 p, vec2 rotor, float r, float th) {
    p.x = abs(p.x);
    p = mat2x2(rotor.y, -rotor.x, rotor.x, rotor.y) * p;
    return max(
        abs(length(p) - r) - th * 0.5,
        length(vec2(p.x, max(
            0.0,
            abs(r - p.y) - th * 0.5
        ))) * sign(p.x));
}

// `size.x` is the length of the prongs, `size.y` is the radius of the prongs.
float sdHorseshoe(vec2 p, vec2 rotor, float radius, vec2 size) {
    rotor = rotorInverse(-rotor.yx);
    p.x = abs(p.x);
    float l = length(p);
    p = mat2(-rotor.x, rotor.y, rotor.y, rotor.x) * p;
    p = vec2(
        (p.y > 0.0 || p.x > 0.0) ? p.x : l * sign(-rotor.x),
        (p.x>0.0) ? p.y : l
    );
    p = vec2(p.x, abs(p.y - radius)) - size;
    return length(max(p, 0.0)) + min(0.0, max(p.x, p.y));
}

float sdVesica(vec2 p, float radius, float distance) {
    p = abs(p);
    float b = sqrt(radius * radius - distance * distance);
    if ((p.y - b) * distance > p.x * b) {
        return length(p - vec2(0.0, b)) * sign(distance);
    } else {
        return length(p - vec2(-distance, 0.0)) - radius;
    }
}

float sdOrientedVesica(vec2 p, vec2 a, vec2 b, float width) {
    float r = 0.5 * length(b - a);
    float d = 0.5 * (r * r - width * width) / width;
    vec2 v = (b - a) / r;
    vec2 c = (b + a) * 0.5;
    vec2 q = 0.5 * abs(mat2(v.y, v.x, -v.x, v.y) * (p - c));
    vec3 h = (r * q.x < d * (q.y - r)) ? vec3(0.0, r, 0.0) : vec3(-d, 0.0, d + width);
    return length(q - h.xy) - h.z;
}

float sdMoon(vec2 p, float offset, float radius_moon, float radius_shadow) {
    p.y = abs(p.y);
    float a = (radius_moon * radius_moon - radius_shadow * radius_shadow + offset * offset)
        / (2.0 * offset);
    float b = sqrt(max(radius_moon * radius_moon - a * a, 0.0));
    if (offset * (p.x * b - p.y * a) > offset * offset * max(b - p.y, 0.0)) {
        return length(p - vec2(a, b));
    }
    return max((length(p) - radius_moon), -(length(p - vec2(offset, 0)) - radius_shadow));
}

float sdRoundedCross(vec2 p, vec2 size, float radius) {
    p /= size.x;
    size.y /= size.x;
    float k = 0.5 * (size.y + 1.0 / size.y);
    p = abs(p);
    if (p.x < 1.0 && p.y < p.x * (k - size.y) + size.y) {
        return (k - sqrt(length2(p - vec2(1, k)))) * size.x - radius;
    } else {
        return sqrt(min(length2(p-vec2(0, size.y)), length2(p - vec2(1, 0)))) * size.x - radius;
    }
}

float sdEgg(vec2 p, float radius_a, float radius_b) {
    const float k = sqrt(3.0);
    p.x = abs(p.x);
    float r = radius_a - radius_b;
    if (p.y > 0.0) {
        return length(p) - r - radius_b;
    } else if (k * (p.x + r) < -p.y) {
        return length(vec2(p.x, p.y + k * r)) - radius_b;
    } else {
        return length(vec2(p.x + r, p.y)) - 2.0 * r - radius_b;
    }    
}

float sdHeart(vec2 p, float radius) {
    p /= radius;
    p.x = abs(p.x);
    if (-p.y + p.x > 0.0) {
        return (length(vec2(p.x, p.y) - vec2(0.25)) - sqrt(2.0) / 4.0) * radius;
    }
    return sqrt(min(
        length2(p),
        length2(vec2(p.x, 1 - p.y) - 0.5 * max(1.0 + p.x - p.y, 0.0)))
    ) * sign(p.x + p.y - 1) * radius;
}

float sdCross(vec2 p, float outer_size, float inner_size, float corner_radius) {
    p = abs(p);
    p = (p.y > p.x) ? p.yx : p.xy;
    vec2  q = p - vec2(outer_size, inner_size);
    float k = max(q.y, q.x);
    vec2  w = (k > 0.0) ? q : vec2(inner_size - p.x, -k);
    return sign(k) * length(max(w, 0.0)) + corner_radius;
}

float sdRoundedX(vec2 p, float x_radius, float line_radius) {
    p = abs(p);
    return length(p - min(p.x + p.y, x_radius) * 0.5) - line_radius;
}

float sdEllipse(vec2 p, vec2 ab) {
    p = abs(p);
    if ( p.x > p.y ) {
        p = p.yx;
        ab = ab.yx;
    }
    float l = ab.y * ab.y - ab.x * ab.x;
    float m = ab.x * p.x / l;
    float m2 = m * m; 
    float n = ab.y * p.y / l;
    float n2 = n * n; 
    float c = (m2 + n2 - 1.0) / 3.0;
    float c3 = c * c * c;
    float q = c3 + m2 * n2 * 2.0;
    float d = c3 + m2 * n2;
    float g = m + m * n2;
    float co;
    if(d < 0.0) {
        float h = acos(q / c3) / 3.0;
        float s = cos(h);
        float t = sin(h) * sqrt(3.0);
        float rx = sqrt(-c * (s + t + 2.0) + m2);
        float ry = sqrt(-c * (s - t + 2.0) + m2);
        co = (ry + sign(l) * rx + abs(g) / (rx * ry) - m) / 2.0;
    } else {
        float h = 2.0 * m * n * sqrt(d);
        float s = sign(q + h) * pow(abs(q + h), 1.0 / 3.0);
        float u = sign(q - h) * pow(abs(q - h), 1.0 / 3.0);
        float rx = -s - u - c * 4.0 + 2.0 * m2;
        float ry = (s - u) * sqrt(3.0);
        float rm = sqrt(rx * rx + ry * ry);
        co = (ry / sqrt(rm - rx) + 2.0 * g / rm - m) / 2.0;
    }
    vec2 r = ab * vec2(co, sqrt(1.0 - co * co));
    return length(r - p) * sign(p.y - r.y);
}

float sdParabola(vec2 pos, float k) {
    pos.x = abs(pos.x);
    float ik = 1.0 / k;
    float p = ik * (pos.y - 0.5 * ik) / 3.0;
    float q = 0.25 * ik * ik * pos.x;
    float h = q * q - p * p * p;
    float r = sqrt(abs(h));
    float x;
    if (h > 0.0) {
        x = pow(q + r,1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        x = 2.0 * cos(atan(r, q) / 3.0) * sqrt(p);
    }
    return length(pos - vec2(x, k * x * x)) * sign(pos.x - x);
}

float sdParabolaSegment(vec2 pos, float width, float height) {
    float half_width = width * 0.5;
    pos.x = abs(pos.x);
    float ik = half_width * half_width / height;
    float p = ik * (height - pos.y - 0.5 * ik) / 3.0;
    float q = pos.x * ik * ik * 0.25;
    float h = q * q - p * p * p;
    float r = sqrt(abs(h));
    float x;
    if (h > 0.0) {
        x = pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        x = 2.0 * cos(atan(r / q) / 3.0) * sqrt(p);
    }
    x = min(x, half_width);
    return length(pos - vec2(x, height - x * x / ik)) * 
        sign(ik * (pos.y - height) + pos.x * pos.x);
}

float sdBezier(vec2 pos, vec2 A, vec2 B, vec2 C) {
    vec2 a = B - A;
    vec2 b = A - 2.0 * B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    float kk = 1.0 / length2(b);
    float kx = kk * dot(a, b);
    float ky = kk * (2.0 * length2(a) + dot(d, b)) / 3.0;
    float kz = kk * dot(d, a);
    float res = 0.0;
    float p = ky - kx * kx;
    float p3 = p * p * p;
    float q = kx * (2.0 * kx * kx - 3.0 * ky) + kz;
    float h = q * q + 4.0 * p3;
    if (h >= 0.0) {
        h = sqrt(h);
        vec2 x = (vec2(h, -h) - q) * 0.5;
        vec2 uv = sign(x) * pow(abs(x), vec2(1.0/ 3.0));
        float t = clamp(uv.x + uv.y - kx, 0.0, 1.0);
        res = length2(d + (c + b * t) * t);
    } else {
        float z = sqrt(-p);
        float v = acos(q / (p * z * 2.0)) / 3.0;
        float m = cos(v);
        float n = sin(v) * 1.732050808;
        vec3 t = clamp(vec3(m + m, -n - m, n - m) * z - kx, 0.0, 1.0);
        res = min(length2(d + (c + b * t.x) * t.x), length2(d + (c + b * t.y) * t.y));
    }
    return sqrt(res);
}

float sdBlobbyCross(vec2 pos, float size, float inset_ratio, float round) {
    pos *= 2 / size;
    pos = abs(pos);
    pos = vec2(abs(pos.x - pos.y), 1.0 - pos.x - pos.y) / sqrt(2.0);

    float p = (inset_ratio - pos.y - 0.25 / inset_ratio) / (6.0 * inset_ratio);
    float q = pos.x / (inset_ratio * inset_ratio * 16.0);
    float h = q * q - p * p * p;
    
    float x;
    if (h > 0.0) {
        float r = sqrt(h);
        x = pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        float r = sqrt(p);
        x = 2.0 * r * cos(acos(q / (p * r)) / 3.0);
    }
    x = min(x, sqrt(2.0) / 2.0);
    
    vec2 z = vec2(x, inset_ratio * (1.0 - 2.0 * x * x)) - pos;
    return length(z) * sign(z.y) / (2 / size) - round;
}

float sdTunnel(vec2 p, vec2 size) {
    size *= 0.5;
    p.x = abs(p.x);
    vec2 q = p - size;

    float d1 = length2(vec2(max(q.x, 0.0), q.y));
    q.x = (p.y > 0.0) ? q.x : length(p) - size.x;
    float d2 = length2(vec2(q.x, max(q.y, 0.0)));
    float d = sqrt(min(d1, d2));
    
    return max(q.x, q.y) < 0.0 ? -d : d;
}

float sdStairs(vec2 p, vec2 size, float n) {
    p.y = 1.0 - p.y;
    vec2 ba = size * n;
    float d = min(length2(p - vec2(clamp(p.x, 0.0, ba.x), 0.0)), 
        length2(p - vec2(ba.x, clamp(p.y, 0.0, ba.y))));
    float s = sign(max(-p.y, p.x - ba.x));

    float dia = length(size);
    p = mat2(size.x, -size.y, size.y, size.x) * p / dia;
    float id = clamp(round(p.x / dia), 0.0, n - 1.0);
    p.x = p.x - id * dia;
    p = mat2(size.x, size.y, -size.y, size.x) * p / dia;

    float hh = size.y / 2.0;
    p.y -= hh;
    if (p.y > hh * sign(p.x)) s = 1.0;
    p = (id < 0.5 || p.x > 0.0) ? p : -p;
    d = min(d, length2(p - vec2(0.0, clamp(p.y, -hh, hh))));
    d = min(d, length2(p - vec2(clamp(p.x, 0.0, size.x), hh)));
    
    return sqrt(d) * s;
}

float sdQuadraticCircle(vec2 p) {
    p = abs(p);
    if (p.y > p.x) p = p.yx;

    float a = p.x - p.y;
    float b = p.x + p.y;
    float c = (2.0 * b - 1.0) / 3.0;
    float h = a * a + c * c * c;
    float t;
    if (h >= 0.0) {
        h = sqrt(h);
        t = sign(h - a) * pow(abs(h - a), 1.0 / 3.0) - pow(h + a, 1.0 / 3.0);
    } else {   
        float z = sqrt(-c);
        float v = acos(a / (c * z)) / 3.0;
        t = -z * (cos(v) + sin(v) * 1.732050808);
    }
    t *= 0.5;
    vec2 w = vec2(-t, t) + 0.75 - t * t - p;
    return length(w) * sign(a * a * 0.5 + b - 1.5);
}

float sdHyperbola(vec2 p, float k, float height) {
    float half_height = height * 0.5;
    p = abs(p);
    p = vec2(p.x - p.y, p.x + p.y) / sqrt(2.0);

    float x2 = p.x * p.x / 16.0;
    float y2 = p.y * p.y / 16.0;
    float r = k * (4.0 * k - p.x * p.y) / 12.0;
    float q = (x2 - y2) * k * k;
    float h = q * q + r * r * r;
    float u;
    if (h < 0.0) {
        float m = sqrt(-r);
        u = m * cos(acos(q / (r * m)) / 3.0);
    } else {
        float m = pow(sqrt(h) - q, 1.0 / 3.0);
        u = (m - r / m) / 2.0;
    }
    float w = sqrt(u + x2);
    float b = k * p.y - x2 * p.x * 2.0;
    float t = p.x / 4.0 - w + sqrt(2.0 * x2 - u + b / w / 4.0);
    t = max(t, sqrt(half_height * half_height * 0.5 + k) - half_height / sqrt(2.0));
    float d = length(p - vec2(t, k / t));
    return p.x * p.y < k ? d : -d;
}

float sdCoolS(vec2 p) {
    float six = (p.y < 0.0) ? -p.x : p.x;
    p.x = abs(p.x);
    p.y = abs(p.y) - 0.2;
    float rex = p.x - min(round(p.x / 0.4), 0.4);
    float aby = abs(p.y - 0.2) - 0.6;
    
    float d = length2(vec2(six, -p.y) - clamp(0.5 * (six - p.y), 0.0, 0.2));
    d = min(d, length2(vec2(p.x, -aby) - clamp(0.5 * (p.x - aby), 0.0, 0.4)));
    d = min(d, length2(vec2(rex, p.y - clamp(p.y, 0.0, 0.4))));
    
    float s = 2.0 * p.x + aby + abs(aby + 0.4) - 0.4;
    return sqrt(d) * sign(s);
}

float sdCircleWave(vec2 p, float ratio, float radius) {
    ratio = PI * 5.0 / 6.0 * max(ratio, 0.0001);
    vec2 co = radius * vec2(sin(ratio), cos(ratio));
    p.x = abs(mod(p.x, co.x * 4.0) - co.x * 2.0);
    vec2 p1 = p;
    vec2 p2 = vec2(abs(p.x - 2.0 * co.x), -p.y + 2.0 * co.y);
    float d1 = ((co.y * p1.x > co.x * p1.y) ? length(p1 - co) : abs(length(p1) - radius));
    float d2 = ((co.y * p2.x > co.x * p2.y) ? length(p2 - co) : abs(length(p2) - radius));
    return min(d1, d2); 
}

float opRound(float sdf, float r) {
    return sdf - r;
}

float opOnion(float sdf, float r) {
  return abs(sdf) - r;
}

float opUnion(float d1, float d2) {
    return min(d1, d2);
}

float opSubtraction(float d1, float d2) {
    return max(-d1, d2);
}

float opIntersection(float d1, float d2) {
    return max(d1, d2);
}

float opXor(float d1, float d2) {
    return max(min(d1, d2), -max(d1, d2));
}

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

float opSmoothSubtraction(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}

float opSmoothIntersection(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

#endif

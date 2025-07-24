#ifndef INCLUDE_GBMS_SDF
#define INCLUDE_GBMS_SDF

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

#include "srgb.glsl"
#include "geom.glsl"
#include "ease.glsl"
#include "c.glsl"

// Samples a SDF with an explicit gradient.
f32 sdSample(f32 sdf, f32 gradient) {
    f32 threshold2 = gradient * 0.5;
    return clamp(ilerp(threshold2, -threshold2, sdf), 0, 1);
}

#ifdef GL_FRAGMENT_SHADER
    // Returns the approximate gradient of the SDF for antialiasing. This could be calculated more
    // precisely by taking length of vec2(dx, dy), but the difference isn't visually perceptible for the
    // purposes of antialiasing.
    f32 sdGradient(f32 sdf) {
        return fwidthFine(sdf);
    }

    // Samples a SDF
    f32 sdSample(f32 sdf) {
        return sdSample(sdf, sdGradient(sdf));
    }
#endif

// Debug output for an SDF.
vec4 sdDebug(f32 sdf, f32 scale) {
    vec3 col = (sdf > 0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
    col *= 1.0 - exp(-6.0 * abs(sdf * scale));
    col *= 0.8 + 0.2 * cos(150.0 * sdf * scale);
    col = mix( col, vec3(1.0), 1.0 - smoothstep(0.0, 0.01, abs(sdf * scale)) );
    return srgbToLinear(vec4(col,1.0));
}

// Debug output for an SDF.
vec4 sdDebug(f32 sdf) {
    return sdDebug(sdf, 1.0);
}

f32 sdCircle(vec2 p, f32 radius) {
    return length(p) - radius;
}

f32 sdBox(vec2 p, vec2 size) {
    vec2 d = abs(p) - size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

f32 sdRoundedBox(vec2 p, vec2 size, vec4 round) {
    round.zy = (p.x > 0.0) ? round.zy : round.wx;
    round.z = (p.y > 0.0) ? round.z : round.y;
    vec2 q = abs(p) - size + round.z;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - round.z;
}

f32 sdChamferBox(vec2 p, vec2 size, f32 chamfer) {
    p = abs(p) - size;

    p = (p.y > p.x) ? p.yx : p.xy;
    p.y += chamfer;
    
    const f32 k = 1.0 - sqrt(2.0);
    if (p.y < 0.0 && p.y + p.x * k < 0.0) return p.x;
    
    if (p.x < p.y) return (p.x + p.y) * sqrt(0.5);
    
    return length(p);
}

f32 sdOrientedBox(vec2 p, vec2 a, vec2 b, f32 width) {
    f32 l = length(b - a);
    vec2 d = (b - a) / l;
    vec2 q = (p - (a + b) * 0.5);
    q = mat2(d.x, -d.y, d.y, d.x) * q;
    q = abs(q) - vec2(l, width) * 0.5;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

f32 sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    f32 h = clamp(dot(pa, ba) / length2(ba), 0.0, 1.0);
    return length(pa - ba * h);
}

f32 _sdNDot(vec2 a, vec2 b) {
    return a.x * b.x - a.y * b.y;
}

f32 sdRhombus(vec2 p, vec2 size)  {
    p = abs(p);
    f32 h = clamp(_sdNDot(size - 2.0 * p, size) / length2(size), -1.0, 1.0);
    f32 d = length(p - 0.5 * size * vec2(1.0 - h,1.0 + h));
    return d * sign(p.x * size.y + p.y * size.x - size.x * size.y);
}

f32 sdTrapezoid(vec2 p, f32 topHalfWidth, f32 bottomHalfWidth, f32 height) {
    vec2 k1 = vec2(bottomHalfWidth, height);
    vec2 k2 = vec2(bottomHalfWidth - topHalfWidth, 2.0 * height);
    p.x = abs(p.x);
    vec2 ca = vec2(p.x - min(p.x, (p.y < 0.0) ? topHalfWidth : bottomHalfWidth), abs(p.y) - height);
    vec2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / length2(k2), 0.0, 1.0);
    f32 s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(length2(ca), length2(cb)));
}

f32 sdParallelogram(vec2 p, f32 halfWidth, f32 halfHeight, f32 skew) {
    vec2 e = vec2(skew, halfHeight);
    p = (p.y < 0.0) ? - p : p;

    vec2  w = p - e;
    w.x -= clamp(w.x, -halfWidth, halfWidth);

    vec2  d = vec2(length2(w), -w.y);
    f32 s = p.x * e.y - p.y * e.x;
    p = (s < 0.0) ? -p : p;
    
    vec2  v = p - vec2(halfWidth, 0);
    v -= e * clamp(dot(v, e) / length2(e), -1.0, 1.0);
    
    d = min(d, vec2(length2(v), halfWidth * halfHeight - abs(s)));
    return sqrt(d.x) * sign(-d.y);
}

f32 sdEquilateralTriangle(vec2 p, f32 halfWidth) {
    const f32 k = sqrt(3.0);
    p.x = abs(p.x) - halfWidth;
    p.y = p.y + halfWidth/k;
    if (p.x + k * p.y > 0.0) p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
    p.x -= clamp(p.x, -2.0 * halfWidth, 0.0);
    return -length(p) * sign(p.y);
}

// Origin at the top of the triangle.
f32 sdIsocolesTriangle(vec2 p, vec2 halfSize) {
    p.x = abs(p.x);
    vec2 a = p - halfSize * clamp(dot(p, halfSize) / length2(halfSize), 0.0, 1.0);
    vec2 b = p - halfSize * vec2(clamp(p.x / halfSize.x, 0.0, 1.0), 1.0);
    f32 s = -sign(halfSize.y);
    vec2 d = min(vec2(length2(a), s * outerProd(p, halfSize)), vec2(length2(b), s * (p.y - halfSize.y)));
    return -sqrt(d.x) * sign(d.y);
}

f32 sdTriangle(vec2 p, vec2 p0, vec2 p1, vec2 p2) {
    vec2 e0 = p1 - p0;
    vec2 e1 = p2 - p1;
    vec2 e2 = p0 - p2;

    vec2 v0 = p - p0;
    vec2 v1 = p - p1;
    vec2 v2 = p - p2;

    vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / length2(e0), 0.0, 1.0);
    vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / length2(e1), 0.0, 1.0);
    vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / length2(e2), 0.0, 1.0);

    f32 s = sign(e0.x * e2.y - e0.y * e2.x);
    vec2 d = min(min(
        vec2(length2(pq0), s * outerProd(v0, e0)),
        vec2(length2(pq1), s * outerProd(v1, e1))),
        vec2(length2(pq2), s * outerProd(v2, e2)));

    return -sqrt(d.x) * sign(d.y);
}

f32 sdUnevenCapsule(vec2 p, f32 topRadius, f32 bottomRadius, f32 height) {
    p.x = abs(p.x);
    f32 b = (topRadius - bottomRadius) / height;
    f32 a = sqrt(1.0 - b * b);
    f32 k = dot(p, vec2(-b, a));
    if (k < 0.0) return length(p) - topRadius;
    if (k > a * height) return length(p - vec2(0.0, height)) - bottomRadius;
    return dot(p, vec2(a, b)) - topRadius;
}

f32 sdPentagon(vec2 p, f32 radius) {
    const vec3 k = vec3(0.809016994, 0.587785252, 0.726542528);
    p.x = abs(p.x);
    p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * vec2(k.x, k.y);
    p -= vec2(clamp(p.x, -radius * k.z, radius * k.z), radius);    
    return length(p) * sign(p.y);
}

f32 sdHexagon(vec2 p, f32 r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

f32 sdOctogon(vec2 p, f32 r) {
    const vec3 k = vec3(-0.9238795325, 0.3826834323, 0.4142135623);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x,k.y);
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}

f32 sdHexagram(vec2 p, f32 r) {
    const vec4 k = vec4(-0.5, 0.8660254038, 0.5773502692, 1.7320508076);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= 2.0 * min(dot(k.yx, p), 0.0) * k.yx;
    p -= vec2(clamp(p.x, r * k.z, r * k.w), r);
    return length(p) * sign(p.y);
}

f32 sdPentagram(vec2 p, f32 r) {
    const f32 k1x = 0.809016994;
    const f32 k2x = 0.309016994;
    const f32 k1y = 0.587785252;
    const f32 k2y = 0.951056516;
    const f32 k1z = 0.726542528;

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

f32 sdStar(vec2 p, f32 radius, u32 points, f32 innerRadiusRatio) {
    f32 m = mix(points, 2.0, innerRadiusRatio);
    f32 an = PI / f32(points);
    f32 en = PI / m;
    vec2  acs = vec2(cos(an), sin(an));
    vec2  ecs = vec2(cos(en), sin(en));

    f32 bn = mod(atan(p.x, p.y), 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));
    p -= radius * acs;
    p += ecs * clamp(-dot(p, ecs), 0.0, radius * acs.y / ecs.y);
    return length(p) * sign(p.x);
}

f32 sdPie(vec2 p, vec2 rotor, f32 radius) {
    rotor = rotorInverse(rotor);
    p.x = abs(p.x);
    f32 l = length(p) - radius;
    f32 m = length(p - rotor * clamp(dot(p, rotor), 0.0, radius));
    return max(l, m * sign(outerProd(p, rotor)));
}

// `cut` ranges from [-0.5, 0.5].
f32 sdCutDisk(vec2 p, f32 radius, f32 cut) {
    f32 w = sqrt(radius * radius - cut * cut);
    p.x = abs(p.x);
    f32 s = max((cut - radius) * p.x * p.x + w * w * (cut + radius - 2.0 * p.y), cut * p.x - w * p.y);
    if (s < 0.0) {
        return length(p) - radius;
    } else if (p.x < w) {
        return cut - p.y;
    } else {
        return length(p - vec2(w, cut));
    }
}

f32 sdArc(vec2 p, vec2 rotor, f32 curveRadius, f32 pathRadius) {
    p.x = abs(p.x);
    if (rotor.y * p.x > -rotor.x * p.y) {
        return length(p - rotorInverse(rotor) * curveRadius) - pathRadius;
    } else {
        return abs(length(p) - curveRadius) - pathRadius;
    }
}

f32 sdRing(vec2 p, vec2 rotor, f32 r, f32 th) {
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
f32 sdHorseshoe(vec2 p, vec2 rotor, f32 radius, vec2 size) {
    rotor = rotorInverse(-rotor.yx);
    p.x = abs(p.x);
    f32 l = length(p);
    p = mat2(-rotor.x, rotor.y, rotor.y, rotor.x) * p;
    p = vec2(
        (p.y > 0.0 || p.x > 0.0) ? p.x : l * sign(-rotor.x),
        (p.x>0.0) ? p.y : l
    );
    p = vec2(p.x, abs(p.y - radius)) - size;
    return length(max(p, 0.0)) + min(0.0, max(p.x, p.y));
}

f32 sdVesica(vec2 p, f32 radius, f32 distance) {
    p = abs(p);
    f32 b = sqrt(radius * radius - distance * distance);
    if ((p.y - b) * distance > p.x * b) {
        return length(p - vec2(0.0, b)) * sign(distance);
    } else {
        return length(p - vec2(-distance, 0.0)) - radius;
    }
}

f32 sdOrientedVesica(vec2 p, vec2 a, vec2 b, f32 width) {
    f32 r = 0.5 * length(b - a);
    f32 d = 0.5 * (r * r - width * width) / width;
    vec2 v = (b - a) / r;
    vec2 c = (b + a) * 0.5;
    vec2 q = 0.5 * abs(mat2(v.y, v.x, -v.x, v.y) * (p - c));
    vec3 h = (r * q.x < d * (q.y - r)) ? vec3(0.0, r, 0.0) : vec3(-d, 0.0, d + width);
    return length(q - h.xy) - h.z;
}

f32 sdMoon(vec2 p, f32 offset, f32 radius_moon, f32 radius_shadow) {
    p.y = abs(p.y);
    f32 a = (radius_moon * radius_moon - radius_shadow * radius_shadow + offset * offset)
        / (2.0 * offset);
    f32 b = sqrt(max(radius_moon * radius_moon - a * a, 0.0));
    if (offset * (p.x * b - p.y * a) > offset * offset * max(b - p.y, 0.0)) {
        return length(p - vec2(a, b));
    }
    return max((length(p) - radius_moon), -(length(p - vec2(offset, 0)) - radius_shadow));
}

f32 sdRoundedCross(vec2 p, vec2 size, f32 radius) {
    p /= size.x;
    size.y /= size.x;
    f32 k = 0.5 * (size.y + 1.0 / size.y);
    p = abs(p);
    if (p.x < 1.0 && p.y < p.x * (k - size.y) + size.y) {
        return (k - sqrt(length2(p - vec2(1, k)))) * size.x - radius;
    } else {
        return sqrt(min(length2(p-vec2(0, size.y)), length2(p - vec2(1, 0)))) * size.x - radius;
    }
}

f32 sdEgg(vec2 p, f32 radius_a, f32 radius_b) {
    const f32 k = sqrt(3.0);
    p.x = abs(p.x);
    f32 r = radius_a - radius_b;
    if (p.y > 0.0) {
        return length(p) - r - radius_b;
    } else if (k * (p.x + r) < -p.y) {
        return length(vec2(p.x, p.y + k * r)) - radius_b;
    } else {
        return length(vec2(p.x + r, p.y)) - 2.0 * r - radius_b;
    }    
}

f32 sdHeart(vec2 p, f32 radius) {
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

f32 sdCross(vec2 p, f32 outer_size, f32 inner_size, f32 corner_radius) {
    p = abs(p);
    p = (p.y > p.x) ? p.yx : p.xy;
    vec2  q = p - vec2(outer_size, inner_size);
    f32 k = max(q.y, q.x);
    vec2  w = (k > 0.0) ? q : vec2(inner_size - p.x, -k);
    return sign(k) * length(max(w, 0.0)) + corner_radius;
}

f32 sdRoundedX(vec2 p, f32 x_radius, f32 line_radius) {
    p = abs(p);
    return length(p - min(p.x + p.y, x_radius) * 0.5) - line_radius;
}

f32 sdEllipse(vec2 p, vec2 ab) {
    p = abs(p);
    if ( p.x > p.y ) {
        p = p.yx;
        ab = ab.yx;
    }
    f32 l = ab.y * ab.y - ab.x * ab.x;
    f32 m = ab.x * p.x / l;
    f32 m2 = m * m; 
    f32 n = ab.y * p.y / l;
    f32 n2 = n * n; 
    f32 c = (m2 + n2 - 1.0) / 3.0;
    f32 c3 = c * c * c;
    f32 q = c3 + m2 * n2 * 2.0;
    f32 d = c3 + m2 * n2;
    f32 g = m + m * n2;
    f32 co;
    if(d < 0.0) {
        f32 h = acos(q / c3) / 3.0;
        f32 s = cos(h);
        f32 t = sin(h) * sqrt(3.0);
        f32 rx = sqrt(-c * (s + t + 2.0) + m2);
        f32 ry = sqrt(-c * (s - t + 2.0) + m2);
        co = (ry + sign(l) * rx + abs(g) / (rx * ry) - m) / 2.0;
    } else {
        f32 h = 2.0 * m * n * sqrt(d);
        f32 s = sign(q + h) * pow(abs(q + h), 1.0 / 3.0);
        f32 u = sign(q - h) * pow(abs(q - h), 1.0 / 3.0);
        f32 rx = -s - u - c * 4.0 + 2.0 * m2;
        f32 ry = (s - u) * sqrt(3.0);
        f32 rm = sqrt(rx * rx + ry * ry);
        co = (ry / sqrt(rm - rx) + 2.0 * g / rm - m) / 2.0;
    }
    vec2 r = ab * vec2(co, sqrt(1.0 - co * co));
    return length(r - p) * sign(p.y - r.y);
}

f32 sdParabola(vec2 pos, f32 k) {
    pos.x = abs(pos.x);
    f32 ik = 1.0 / k;
    f32 p = ik * (pos.y - 0.5 * ik) / 3.0;
    f32 q = 0.25 * ik * ik * pos.x;
    f32 h = q * q - p * p * p;
    f32 r = sqrt(abs(h));
    f32 x;
    if (h > 0.0) {
        x = pow(q + r,1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        x = 2.0 * cos(atan(r, q) / 3.0) * sqrt(p);
    }
    return length(pos - vec2(x, k * x * x)) * sign(pos.x - x);
}

f32 sdParabolaSegment(vec2 pos, f32 width, f32 height) {
    f32 half_width = width * 0.5;
    pos.x = abs(pos.x);
    f32 ik = half_width * half_width / height;
    f32 p = ik * (height - pos.y - 0.5 * ik) / 3.0;
    f32 q = pos.x * ik * ik * 0.25;
    f32 h = q * q - p * p * p;
    f32 r = sqrt(abs(h));
    f32 x;
    if (h > 0.0) {
        x = pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        x = 2.0 * cos(atan(r / q) / 3.0) * sqrt(p);
    }
    x = min(x, half_width);
    return length(pos - vec2(x, height - x * x / ik)) * 
        sign(ik * (pos.y - height) + pos.x * pos.x);
}

f32 sdBezier(vec2 pos, vec2 A, vec2 B, vec2 C) {
    vec2 a = B - A;
    vec2 b = A - 2.0 * B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    f32 kk = 1.0 / length2(b);
    f32 kx = kk * dot(a, b);
    f32 ky = kk * (2.0 * length2(a) + dot(d, b)) / 3.0;
    f32 kz = kk * dot(d, a);
    f32 res = 0.0;
    f32 p = ky - kx * kx;
    f32 p3 = p * p * p;
    f32 q = kx * (2.0 * kx * kx - 3.0 * ky) + kz;
    f32 h = q * q + 4.0 * p3;
    if (h >= 0.0) {
        h = sqrt(h);
        vec2 x = (vec2(h, -h) - q) * 0.5;
        vec2 uv = sign(x) * pow(abs(x), vec2(1.0/ 3.0));
        f32 t = clamp(uv.x + uv.y - kx, 0.0, 1.0);
        res = length2(d + (c + b * t) * t);
    } else {
        f32 z = sqrt(-p);
        f32 v = acos(q / (p * z * 2.0)) / 3.0;
        f32 m = cos(v);
        f32 n = sin(v) * 1.732050808;
        vec3 t = clamp(vec3(m + m, -n - m, n - m) * z - kx, 0.0, 1.0);
        res = min(length2(d + (c + b * t.x) * t.x), length2(d + (c + b * t.y) * t.y));
    }
    return sqrt(res);
}

f32 sdBlobbyCross(vec2 pos, f32 size, f32 inset_ratio, f32 round) {
    pos *= 2 / size;
    pos = abs(pos);
    pos = vec2(abs(pos.x - pos.y), 1.0 - pos.x - pos.y) / sqrt(2.0);

    f32 p = (inset_ratio - pos.y - 0.25 / inset_ratio) / (6.0 * inset_ratio);
    f32 q = pos.x / (inset_ratio * inset_ratio * 16.0);
    f32 h = q * q - p * p * p;
    
    f32 x;
    if (h > 0.0) {
        f32 r = sqrt(h);
        x = pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
    } else {
        f32 r = sqrt(p);
        x = 2.0 * r * cos(acos(q / (p * r)) / 3.0);
    }
    x = min(x, sqrt(2.0) / 2.0);
    
    vec2 z = vec2(x, inset_ratio * (1.0 - 2.0 * x * x)) - pos;
    return length(z) * sign(z.y) / (2 / size) - round;
}

f32 sdTunnel(vec2 p, vec2 size) {
    size *= 0.5;
    p.x = abs(p.x);
    vec2 q = p - size;

    f32 d1 = length2(vec2(max(q.x, 0.0), q.y));
    q.x = (p.y > 0.0) ? q.x : length(p) - size.x;
    f32 d2 = length2(vec2(q.x, max(q.y, 0.0)));
    f32 d = sqrt(min(d1, d2));
    
    return max(q.x, q.y) < 0.0 ? -d : d;
}

f32 sdStairs(vec2 p, vec2 size, f32 n) {
    p.y = 1.0 - p.y;
    vec2 ba = size * n;
    f32 d = min(length2(p - vec2(clamp(p.x, 0.0, ba.x), 0.0)), 
        length2(p - vec2(ba.x, clamp(p.y, 0.0, ba.y))));
    f32 s = sign(max(-p.y, p.x - ba.x));

    f32 dia = length(size);
    p = mat2(size.x, -size.y, size.y, size.x) * p / dia;
    f32 id = clamp(round(p.x / dia), 0.0, n - 1.0);
    p.x = p.x - id * dia;
    p = mat2(size.x, size.y, -size.y, size.x) * p / dia;

    f32 hh = size.y / 2.0;
    p.y -= hh;
    if (p.y > hh * sign(p.x)) s = 1.0;
    p = (id < 0.5 || p.x > 0.0) ? p : -p;
    d = min(d, length2(p - vec2(0.0, clamp(p.y, -hh, hh))));
    d = min(d, length2(p - vec2(clamp(p.x, 0.0, size.x), hh)));
    
    return sqrt(d) * s;
}

f32 sdQuadraticCircle(vec2 p) {
    p = abs(p);
    if (p.y > p.x) p = p.yx;

    f32 a = p.x - p.y;
    f32 b = p.x + p.y;
    f32 c = (2.0 * b - 1.0) / 3.0;
    f32 h = a * a + c * c * c;
    f32 t;
    if (h >= 0.0) {
        h = sqrt(h);
        t = sign(h - a) * pow(abs(h - a), 1.0 / 3.0) - pow(h + a, 1.0 / 3.0);
    } else {   
        f32 z = sqrt(-c);
        f32 v = acos(a / (c * z)) / 3.0;
        t = -z * (cos(v) + sin(v) * 1.732050808);
    }
    t *= 0.5;
    vec2 w = vec2(-t, t) + 0.75 - t * t - p;
    return length(w) * sign(a * a * 0.5 + b - 1.5);
}

f32 sdHyperbola(vec2 p, f32 k, f32 height) {
    f32 half_height = height * 0.5;
    p = abs(p);
    p = vec2(p.x - p.y, p.x + p.y) / sqrt(2.0);

    f32 x2 = p.x * p.x / 16.0;
    f32 y2 = p.y * p.y / 16.0;
    f32 r = k * (4.0 * k - p.x * p.y) / 12.0;
    f32 q = (x2 - y2) * k * k;
    f32 h = q * q + r * r * r;
    f32 u;
    if (h < 0.0) {
        f32 m = sqrt(-r);
        u = m * cos(acos(q / (r * m)) / 3.0);
    } else {
        f32 m = pow(sqrt(h) - q, 1.0 / 3.0);
        u = (m - r / m) / 2.0;
    }
    f32 w = sqrt(u + x2);
    f32 b = k * p.y - x2 * p.x * 2.0;
    f32 t = p.x / 4.0 - w + sqrt(2.0 * x2 - u + b / w / 4.0);
    t = max(t, sqrt(half_height * half_height * 0.5 + k) - half_height / sqrt(2.0));
    f32 d = length(p - vec2(t, k / t));
    return p.x * p.y < k ? d : -d;
}

f32 sdCoolS(vec2 p) {
    f32 six = (p.y < 0.0) ? -p.x : p.x;
    p.x = abs(p.x);
    p.y = abs(p.y) - 0.2;
    f32 rex = p.x - min(round(p.x / 0.4), 0.4);
    f32 aby = abs(p.y - 0.2) - 0.6;
    
    f32 d = length2(vec2(six, -p.y) - clamp(0.5 * (six - p.y), 0.0, 0.2));
    d = min(d, length2(vec2(p.x, -aby) - clamp(0.5 * (p.x - aby), 0.0, 0.4)));
    d = min(d, length2(vec2(rex, p.y - clamp(p.y, 0.0, 0.4))));
    
    f32 s = 2.0 * p.x + aby + abs(aby + 0.4) - 0.4;
    return sqrt(d) * sign(s);
}

f32 sdCircleWave(vec2 p, f32 ratio, f32 radius) {
    ratio = PI * 5.0 / 6.0 * max(ratio, 0.0001);
    vec2 co = radius * vec2(sin(ratio), cos(ratio));
    p.x = abs(mod(p.x, co.x * 4.0) - co.x * 2.0);
    vec2 p1 = p;
    vec2 p2 = vec2(abs(p.x - 2.0 * co.x), -p.y + 2.0 * co.y);
    f32 d1 = ((co.y * p1.x > co.x * p1.y) ? length(p1 - co) : abs(length(p1) - radius));
    f32 d2 = ((co.y * p2.x > co.x * p2.y) ? length(p2 - co) : abs(length(p2) - radius));
    return min(d1, d2); 
}

f32 opRound(f32 sdf, f32 r) {
    return sdf - r;
}

f32 opOnion(f32 sdf, f32 r) {
  return abs(sdf) - r;
}

f32 opUnion(f32 d1, f32 d2) {
    return min(d1, d2);
}

f32 opSubtraction(f32 d1, f32 d2) {
    return max(-d1, d2);
}

f32 opIntersection(f32 d1, f32 d2) {
    return max(d1, d2);
}

f32 opXor(f32 d1, f32 d2) {
    return max(min(d1, d2), -max(d1, d2));
}

f32 opSmoothUnion(f32 d1, f32 d2, f32 k) {
    f32 h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

f32 opSmoothSubtraction(f32 d1, f32 d2, f32 k) {
    f32 h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}

f32 opSmoothIntersection(f32 d1, f32 d2, f32 k) {
    f32 h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

#endif

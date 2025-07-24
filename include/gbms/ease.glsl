#ifndef INCLUDE_GBMS_EASE
#define INCLUDE_GBMS_EASE

// These functions are kept in sync with:
//
// https://github.com/Games-by-Mason/Tween/
// 
// Documentation on their origin is present in that repo.

#include "c.glsl"
#include "constants.glsl"

f32 ilerp(f32 a, f32 b, f32 f) {
    return (f - a) / (b - a);
}

f32 remap(f32 in_start, f32 in_end, f32 out_start, f32 out_end, f32 f) {
    f32 t = ilerp(in_start, in_end, f);
    return mix(out_start, out_end, t);
}

f32 sinIn(f32 t) {
    return 1.0 - cos(t * PI * 0.5);
}

f32 sinOut(f32 t) {
    return sin(t * PI * 0.5);
}

f32 sinInOut(f32 t) {
    return -(cos(PI * t) - 1.0) * 0.5;
}

f32 quadIn(f32 t) {
    return t * t;
}

f32 quadOut(f32 t) {
    f32 inv = 1.0 - t;
    return fma(-inv, inv, 1.0);
}

f32 quadInOut(f32 t) {
    if (t < 0.5) {
        return 2.0 * t * t;
    } else {
        return fma(4.0, t, -1.0) - 2.0 * t * t;
    }
}

f32 cubicIn(f32 t) {
    return t * t * t;
}

f32 cubicOut(f32 t) {
    f32 inv = 1.0 - t;
    return fma(inv * inv, -inv, 1.0);
}

f32 cubicInOut(f32 t) {
    if (t < 0.5) {
        return 4 * t * t * t;
    } else {
        f32 c = fma(-2.0, t, 2.0);
        return fma(-c / 2.0, c * c, 1.0);
    }
}

f32 quartIn(f32 t) {
    f32 t2 = t * t;
    return t2  * t2;
}

f32 quartOut(f32 t) {
    f32 inv = 1.0 - t;
    f32 squared = inv * inv;
    return fma(-squared, squared, 1.0);
}

f32 quartInOut(f32 t) {
    if (t < 0.5) {
        f32 t2 = t * t;
        return 8.0 * t2 * t2;
    } else {
        f32 q = fma(-2.0, t, 2.0);
        return fma(-q / 2.0, q * q * q, 1.0);
    }
}

f32 quintIn(f32 t) {
    f32 t2 = t * t;
    return t2 * t2 * t;
}

f32 quintOut(f32 t) {
    f32 inv = 1.0 - t;
    f32 squared = inv * inv;
    return fma(-squared, squared * inv, 1.0);
}

f32 quintInOut(f32 t) {
    if (t < 0.5) {
        f32 t2 = t * t;
        return 16 * t2 * t2 * t;
    } else {
        f32 q = fma(-2.0, t, 2.0);
        return fma(-q * q / 2.0, q * q * q, 1.0);
    }
}

f32 expIn(f32 t) {
    if (t <= 0.0) return 0;
    return pow(2, fma(10.0, t, -10.0));
}

f32 expOut(f32 t) {
    return 1.0 - expIn(1.0 - t);
}

f32 expInOut(f32 t) {
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;
    if (t < 0.5) {
        return pow(2.0, fma(20.0, t, -10.0)) / 2.0;
    } else {
        return 1.0 - pow(2.0, fma(-20.0, t, 10.0)) / 2.0;
    }
}

f32 circIn(f32 t) {
    return 1.0 - sqrt(fma(-t, t, 1.0));
}

f32 circOut(f32 t) {
    f32 inv = t - 1.0;
    return sqrt(fma(-inv, inv, 1.0));
}

f32 circInOut(f32 t) {
    if (t < 0.5) {
        return (1.0 - sqrt(fma(-4.0 * t, t, 1.0))) / 2.0;
    } else {
        f32 s = fma(-2.0, t, 2.0);
        return (sqrt(fma(-s, s, 1.0)) + 1.0) / 2.0;
    }
}

f32 BACK_IN_BACK_DEFAULT = 1.70158;

f32 backIn(f32 t, f32 back) {
    f32 t2 = t * t;
    f32 t3 = t2 * t;
    return fma(t3, back, fma(-t2, back, t3));
}

f32 backIn(f32 t) {
    return backIn(t, BACK_IN_BACK_DEFAULT);
}

f32 backOut(f32 t, f32 back) {
    f32 inv = t - 1.0;
    f32 inv2 = inv * inv;
    f32 inv3 = inv2 * inv;
    return fma(back, inv3, fma(back, inv2, inv3 + 1));
}

f32 backOut(f32 t) {
    return backOut(t, BACK_IN_BACK_DEFAULT);
}

f32 backInOut(f32 t, f32 back) {
    f32 overshoot_adjusted = back * 1.525;

    if (t < 0.5) {
        f32 a = 2.0 * t;
        f32 b = fma(overshoot_adjusted + 1.0, 2.0 * t, -overshoot_adjusted);
        return (a * a * b) * 0.5;
    } else {
        f32 a = fma(2.0, t, -2.0);
        f32 b = fma(overshoot_adjusted + 1, fma(t, 2.0, -2.0), overshoot_adjusted);
        return fma(a * a, b, 2.0) * 0.5;
    }
}

f32 backInOut(f32 t) {
    return backInOut(t, BACK_IN_BACK_DEFAULT);
}


f32 ELASTIC_IN_AMPLITUDE_DEFAULT = 1.0;
f32 ELASTIC_IN_PERIOD_DEFAULT = 0.3;

f32 elasticIn(f32 t, f32 amplitude, f32 period) {
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;

    f32 m = PI / 4.0;
    if (amplitude <= 1.0) {
        amplitude = 1.0;
        m = period / 4;
    } else {
        m = period / (2 * PI) * asin(1 / amplitude);
    }

    return -amplitude * pow(2.0, fma(10.0, t, -10.0)) * sin(
        (t - 1 - m) * 2 * PI / period
    );
}

f32 elasticIn(f32 t) {
    return elasticIn(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

f32 elasticOut(f32 t, f32 amplitude, f32 period) {
    return 1.0 - elasticIn(1.0 - t, amplitude, period);
}

f32 elasticOut(f32 t) {
    return elasticOut(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

f32 elasticInOut(f32 t, f32 amplitude, f32 period) {
    if (t < 0.5) {
        return elasticIn(2.0 * t, amplitude, period) * 0.5;
    } else {
        return 1.0 - elasticIn(fma(-2.0, t, 2.0), amplitude, period) * 0.5;
    }
}

f32 elasticInOut(f32 t) {
    return elasticInOut(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

/// See `bounceIn`.
f32 bounceOut(f32 t) {
    f32 a = 7.5625;
    f32 b = 2.75;

    if (t < 1.0 / b) {
        return a * t * t;
    } else if (t < 2.0 / b) {
        f32 t2 = t - 1.5 / b;
        return fma(a, t2 * t2, 0.75);
    } else if (t < 2.5 / b) {
        f32 t2 = t - 2.25 / b;
        return fma(a, t2 * t2, 0.9375);
    } else {
        f32 t2 = t - 2.625 / b;
        return fma(a, t2 * t2, 0.984375);
    }
}

f32 bounceIn(f32 t) {
    return 1.0 - bounceOut(1.0 - t);
}

f32 bounceInOut(f32 t) {
    if (t < 0.5) {
        return bounceIn(2.0 * t) * 0.5;
    } else {
        return 1 - bounceIn(fma(-2.0, t, 2)) * 0.5;
    }
}

f32 smoothstep(f32 t) {
    return t * t * fma(-2.0, t, 3.0);
}

f32 smootherstep(f32 t) {
    f32 t3 = t * t * t;
    f32 t4 = t3 * t;
    f32 t5 = t4 * t;
    return fma(6, t5, fma(-15.0, t4, 10.0 * t3));
}

f32 steps(f32 t, f32 count) {
    return floor(count * t + 1.0) / (count + 1.0);
}

#endif

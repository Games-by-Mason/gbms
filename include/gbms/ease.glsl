#ifndef INCLUDE_GBMS_EASE
#define INCLUDE_GBMS_EASE

// These functions are kept in sync with:
//
// https://github.com/Games-by-Mason/Tween/
// 
// Documentation on their origin is present in that repo.

#include "constants.glsl"

float ilerp(float a, float b, float f) {
    return (f - a) / (b - a);
}

float remap(float in_start, float in_end, float out_start, float out_end, float f) {
    float t = ilerp(in_start, in_end, f);
    return mix(out_start, out_end, t);
}

float sinIn(float t) {
    return 1.0 - cos(t * PI * 0.5);
}

float sinOut(float t) {
    return sin(t * PI * 0.5);
}

float sinInOut(float t) {
    return -(cos(PI * t) - 1.0) * 0.5;
}

float quadIn(float t) {
    return t * t;
}

float quadOut(float t) {
    float inv = 1.0 - t;
    return fma(-inv, inv, 1.0);
}

float quadInOut(float t) {
    if (t < 0.5) {
        return 2.0 * t * t;
    } else {
        return fma(4.0, t, -1.0) - 2.0 * t * t;
    }
}

float cubicIn(float t) {
    return t * t * t;
}

float cubicOut(float t) {
    float inv = 1.0 - t;
    return fma(inv * inv, -inv, 1.0);
}

float cubicInOut(float t) {
    if (t < 0.5) {
        return 4 * t * t * t;
    } else {
        float c = fma(-2.0, t, 2.0);
        return fma(-c / 2.0, c * c, 1.0);
    }
}

float quartIn(float t) {
    float t2 = t * t;
    return t2  * t2;
}

float quartOut(float t) {
    float inv = 1.0 - t;
    float squared = inv * inv;
    return fma(-squared, squared, 1.0);
}

float quartInOut(float t) {
    if (t < 0.5) {
        float t2 = t * t;
        return 8.0 * t2 * t2;
    } else {
        float q = fma(-2.0, t, 2.0);
        return fma(-q / 2.0, q * q * q, 1.0);
    }
}

float quintIn(float t) {
    float t2 = t * t;
    return t2 * t2 * t;
}

float quintOut(float t) {
    float inv = 1.0 - t;
    float squared = inv * inv;
    return fma(-squared, squared * inv, 1.0);
}

float quintInOut(float t) {
    if (t < 0.5) {
        float t2 = t * t;
        return 16 * t2 * t2 * t;
    } else {
        float q = fma(-2.0, t, 2.0);
        return fma(-q * q / 2.0, q * q * q, 1.0);
    }
}

float expIn(float t) {
    if (t <= 0.0) return 0;
    return pow(2, fma(10.0, t, -10.0));
}

float expOut(float t) {
    return 1.0 - expIn(1.0 - t);
}

float expInOut(float t) {
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;
    if (t < 0.5) {
        return pow(2.0, fma(20.0, t, -10.0)) / 2.0;
    } else {
        return 1.0 - pow(2.0, fma(-20.0, t, 10.0)) / 2.0;
    }
}

float circIn(float t) {
    return 1.0 - sqrt(fma(-t, t, 1.0));
}

float circOut(float t) {
    float inv = t - 1.0;
    return sqrt(fma(-inv, inv, 1.0));
}

float circInOut(float t) {
    if (t < 0.5) {
        return (1.0 - sqrt(fma(-4.0 * t, t, 1.0))) / 2.0;
    } else {
        float s = fma(-2.0, t, 2.0);
        return (sqrt(fma(-s, s, 1.0)) + 1.0) / 2.0;
    }
}

float BACK_IN_BACK_DEFAULT = 1.70158;

float backIn(float t, float back) {
    float t2 = t * t;
    float t3 = t2 * t;
    return fma(t3, back, fma(-t2, back, t3));
}

float backIn(float t) {
    return backIn(t, BACK_IN_BACK_DEFAULT);
}

float backOut(float t, float back) {
    float inv = t - 1.0;
    float inv2 = inv * inv;
    float inv3 = inv2 * inv;
    return fma(back, inv3, fma(back, inv2, inv3 + 1));
}

float backOut(float t) {
    return backOut(t, BACK_IN_BACK_DEFAULT);
}

float backInOut(float t, float back) {
    float overshoot_adjusted = back * 1.525;

    if (t < 0.5) {
        float a = 2.0 * t;
        float b = fma(overshoot_adjusted + 1.0, 2.0 * t, -overshoot_adjusted);
        return (a * a * b) * 0.5;
    } else {
        float a = fma(2.0, t, -2.0);
        float b = fma(overshoot_adjusted + 1, fma(t, 2.0, -2.0), overshoot_adjusted);
        return fma(a * a, b, 2.0) * 0.5;
    }
}

float backInOut(float t) {
    return backInOut(t, BACK_IN_BACK_DEFAULT);
}


float ELASTIC_IN_AMPLITUDE_DEFAULT = 1.0;
float ELASTIC_IN_PERIOD_DEFAULT = 0.3;

float elasticIn(float t, float amplitude, float period) {
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;

    float m = PI / 4.0;
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

float elasticIn(float t) {
    return elasticIn(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

float elasticOut(float t, float amplitude, float period) {
    return 1.0 - elasticIn(1.0 - t, amplitude, period);
}

float elasticOut(float t) {
    return elasticOut(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

float elasticInOut(float t, float amplitude, float period) {
    if (t < 0.5) {
        return elasticIn(2.0 * t, amplitude, period) * 0.5;
    } else {
        return 1.0 - elasticIn(fma(-2.0, t, 2.0), amplitude, period) * 0.5;
    }
}

float elasticInOut(float t) {
    return elasticInOut(t, ELASTIC_IN_AMPLITUDE_DEFAULT, ELASTIC_IN_PERIOD_DEFAULT);
}

/// See `bounceIn`.
float bounceOut(float t) {
    float a = 7.5625;
    float b = 2.75;

    if (t < 1.0 / b) {
        return a * t * t;
    } else if (t < 2.0 / b) {
        float t2 = t - 1.5 / b;
        return fma(a, t2 * t2, 0.75);
    } else if (t < 2.5 / b) {
        float t2 = t - 2.25 / b;
        return fma(a, t2 * t2, 0.9375);
    } else {
        float t2 = t - 2.625 / b;
        return fma(a, t2 * t2, 0.984375);
    }
}

float bounceIn(float t) {
    return 1.0 - bounceOut(1.0 - t);
}

float bounceInOut(float t) {
    if (t < 0.5) {
        return bounceIn(2.0 * t) * 0.5;
    } else {
        return 1 - bounceIn(fma(-2.0, t, 2)) * 0.5;
    }
}

float smoothstep(float t) {
    return t * t * fma(-2.0, t, 3.0);
}

float smootherstep(float t) {
    float t3 = t * t * t;
    float t4 = t3 * t;
    float t5 = t4 * t;
    return fma(6, t5, fma(-15.0, t4, 10.0 * t3));
}

float steps(float t, float count) {
    return floor(count * t + 1.0) / (count + 1.0);
}

#endif

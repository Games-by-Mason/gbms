#ifndef INCLUDE_GBMS_EASE
#define INCLUDE_GBMS_EASE

float easeSmootherstep(float t) {
    float t3 = t * t * t;
    float t4 = t3 * t;
    float t5 = t4 * t;
    return fma(6, t5, fma(-15.0, t4, 10.0 * t3));
}

float easeSmoothstep(float t) {
    return t * t * fma(-2.0, t, 3.0);
}

float easeIlerp(float a, float b, float f) {
    return (f - a) / (b - a);
}

float easeRemap(float in_start, float in_end, float out_start, float out_end, float f) {
    float t = easeIlerp(in_start, in_end, f);
    return mix(out_start, out_end, t);
}

#endif
#ifndef INCLUDE_GBMS_UNPACK
#define INCLUDE_GBMS_UNPACK

#include "c.glsl"

#define unpackF16x2 unpackHalf2x16
#define u32BitsToF32 uintBitsToFloat
#define f32BitsToU32 floatBitsToInt

ivec2 unpackU16x2(u32 n) {
    return ivec2(
        n & 0x0000FFFF,
        n >> 16
    );
}

#endif

#ifndef INCLUDE_GBMS_CONSTANTS
#define INCLUDE_GBMS_CONSTANTS

#include "c.glsl"

#ifdef __STDC__
	const u32 U32_MAX = (u32)0xFFFFFFFF;
#else
	const u32 U32_MAX = 0xFFFFFFFF;
#endif

#ifdef __STDC__
	const f32 U32_MAX_RECIP = 1.0f / (f32)0xFFFFFFFFu;
#else
	const f32 U32_MAX_RECIP = 1.0f / f32(0xFFFFFFFFu);
#endif

const f32 F32_MAX_CONSEC = 16777216.0;

#ifdef __STDC__
	#include <math.h>
	const f32 INF = INFINITY;
#else
	const f32 INF = 1.0 / 0.0;
#endif

const f32 PI = 3.14159265358979323846264338327950288419716939937510;
// Conditional due to https://codeberg.org/ziglang/zig/issues/30041
#ifndef __STDC__
	const f32 F32_MAX = 3.40282347E+38;
#endif

#endif

#ifndef INCLUDE_GBMS_C
#define INCLUDE_GBMS_C

// When compiled as C, this file provides typedefs and macros that help make GLSL files usable as C
// headers. This allows sharing constants and structs across GLSL and C or C compatible languages.
//
// Also provides explicitly sized numeric types.

// Typedef C structs to remove the requirement to prefix them with the struct keyword
#ifdef __STDC__
	#define EXPORT_STRUCT(name) typedef struct name name
#else
	#define EXPORT_STRUCT(name)
#endif

// Macros & typedefs for matching C and GLSL types
#ifdef __STDC__
	#include <stdint.h>

	typedef uint32_t bool;
	typedef uint32_t u32;
	typedef int32_t i32;
	typedef float f32;
	typedef double f64;

	typedef struct { bool x; bool y; } bvec2;
	typedef struct { bool x; bool y; bool z; } bvec3;
	typedef struct { bool x; bool y; bool z; bool w; } bvec4;

	#define bvec2(x, y) (bvec2){ x, y }
	#define bvec3(x, y, z) (bvec3){ x, y, z }
	#define bvec4(x, y, z, w) (bvec3){ x, y, z, w }

	typedef struct { i32 x; i32 y; } ivec2;
	typedef struct { i32 x; i32 y; i32 z; } ivec3;
	typedef struct { i32 x; i32 y; i32 z; i32 w; } ivec4;

	#define ivec2(x, y) (ivec2){ x, y }
	#define ivec3(x, y, z) (ivec3){ x, y, z }
	#define ivec4(x, y, z, w) (ivec3){ x, y, z, w }

	typedef struct { u32 x; u32 y; } uvec2;
	typedef struct { u32 x; u32 y; u32 z; } uvec3;
	typedef struct { u32 x; u32 y; u32 z; u32 w; } uvec4;

	#define uvec2(x, y) (uvec2){ x, y }
	#define uvec3(x, y, z) (uvec3){ x, y, z }
	#define uvec4(x, y, z, w) (uvec3){ x, y, z, w }

	typedef struct { f32 x; f32 y; } vec2;
	typedef struct { f32 x; f32 y; f32 z; } vec3;
	typedef struct { f32 x; f32 y; f32 z; f32 w; } vec4;

	#define vec2(x, y) (vec2){ x, y }
	#define vec3(x, y, z) (vec3){ x, y, z }
	#define vec4(x, y, z, w) (vec3){ x, y, z, w }

	typedef struct { f64 x; f64 y; } dvec2;
	typedef struct { f64 x; f64 y; f64 z; } dvec3;
	typedef struct { f64 x; f64 y; f64 z; f64 w; } dvec4;

	#define dvec2(x, y) (dvec2){ x, y }
	#define dvec3(x, y, z) (dvec3){ x, y, z }
	#define dvec4(x, y, z, w) (dvec3){ x, y, z, w }

	typedef f32 mat2x2[4];
	typedef f32 mat2x3[6];
	typedef f32 mat2x4[8];

	typedef f32 mat3x2[6];
	typedef f32 mat3x3[9];
	typedef f32 mat3x4[12];

	typedef f32 mat4x2[8];
	typedef f32 mat4x3[12];
	typedef f32 mat4x4[16];
#else
	#define u32 uint
	#define i32 int
	#define f32 float
	#define f64 double
#endif

// Math functions that are shared between C and GLSL
u32 divCeil(u32 a, u32 b) {
	if (a == 0 || b == 0) return 0;
	return ((a - 1u) / b) + 1u;
}

#endif


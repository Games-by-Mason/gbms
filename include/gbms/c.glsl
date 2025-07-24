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

// Macros for C versions of GLSL primitives
#ifdef __STDC__
	#include <stdint.h>

	#define bool uint32_t
	#define u32 uint32_t
	#define i32 int32_t
	#define f32 float
	#define f64 double

	typedef bool bvec2[2];
	typedef bool bvec3[3];
	typedef bool bvec4[4];

	typedef i32 ivec2[2];
	typedef i32 ivec3[3];
	typedef i32 ivec4[4];

	typedef u32 uvec2[2];
	typedef u32 uvec3[3];
	typedef u32 uvec4[4];

	typedef f32 vec2[2];
	typedef f32 vec3[3];
	typedef f32 vec4[4];

	typedef f64 dvec2[2];
	typedef f64 dvec3[3];
	typedef f64 dvec4[4];

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

#endif

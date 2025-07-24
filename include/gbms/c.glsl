#ifndef INCLUDE_GBMS_C
#define INCLUDE_GBMS_C

// When compiled as C, this file provides typedefs and macros that help make GLSL files usable as C
// headers. This allows sharing constants and structs across GLSL and C or C compatible languages.

// Typedef C structs to remove the requirement to prefix them with the struct keyword
#ifdef __STDC__
	#define EXPORT_STRUCT(name) typedef struct name name
#else
	#define EXPORT_STRUCT(name)
#endif

// Macros for C versions of GLSL primitives
#ifdef __STDC__
	typedef unsigned int uint;
	typedef int bool;

	typedef bool bvec2[2];
	typedef bool bvec3[3];
	typedef bool bvec4[4];

	typedef int ivec2[2];
	typedef int ivec3[3];
	typedef int ivec4[4];

	typedef uint uvec2[2];
	typedef uint uvec3[3];
	typedef uint uvec4[4];

	typedef float vec2[2];
	typedef float vec3[3];
	typedef float vec4[4];

	typedef double dvec2[2];
	typedef double dvec3[3];
	typedef double dvec4[4];

	typedef float mat2x2[4];
	typedef float mat2x3[6];
	typedef float mat2x4[8];

	typedef float mat3x2[6];
	typedef float mat3x3[9];
	typedef float mat3x4[12];

	typedef float mat4x2[8];
	typedef float mat4x3[12];
	typedef float mat4x4[16];
#endif

#endif

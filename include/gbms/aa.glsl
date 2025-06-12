#ifndef INCLUDE_GBMS_AA
#define INCLUDE_GBMS_AA

// Box super sampling is equivalent to a box blur.
const uint aa_box1x2_samples = 2;
const vec2[aa_box1x2_samples] aa_box1x2_offsets = vec2[aa_box1x2_samples](
	vec2(+0.00, +0.25),
	vec2(+0.00, -0.25)
);
const float[aa_box1x2_samples] aa_box1x2_weights = float[aa_box1x2_samples](
	1,
	1
);
const float aa_box1x2_gain = 0.5;

const uint aa_box2x1_samples = 2;
const vec2[aa_box2x1_samples] aa_box2x1_offsets = vec2[aa_box2x1_samples](
	vec2(-0.25, +0.00), vec2(+0.25, +0.00)
);
const float[aa_box2x1_samples] aa_box2x1_weights = float[aa_box2x1_samples](
	1, 1
);
const float aa_box2x1_gain = 0.5;

const uint aa_box2x2_samples = 4;
const vec2[aa_box2x2_samples] aa_box2x2_offsets = vec2[aa_box2x2_samples](
	vec2(-0.25, +0.25), vec2(+0.25, +0.25),
	vec2(-0.25, -0.25), vec2(+0.25, -0.25)
);
const float[aa_box2x2_samples] aa_box2x2_weights = float[aa_box2x2_samples](
	1, 1,
	1, 1
);
const float aa_box2x2_gain = 0.25;

const uint aa_box4x4_samples = 16;
const vec2[aa_box4x4_samples] aa_box4x4_offsets = vec2[aa_box4x4_samples](
	vec2(-0.375, +0.375), vec2(-0.125, +0.375), vec2(+0.125, +0.375), vec2(+0.375, +0.375),
	vec2(-0.375, +0.125), vec2(-0.125, +0.125), vec2(+0.125, +0.125), vec2(+0.375, +0.125),
	vec2(-0.375, -0.125), vec2(-0.125, -0.125), vec2(+0.125, -0.125), vec2(+0.375, -0.125),
	vec2(-0.375, -0.375), vec2(-0.125, -0.375), vec2(+0.125, -0.375), vec2(+0.375, -0.375)
);
const float[aa_box4x4_samples] aa_box4x4_weights = float[aa_box4x4_samples](
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1
);
const float aa_box4x4_gain = 0.0625;

const uint aa_box8x8_samples = 64;
const vec2[aa_box8x8_samples] aa_box8x8_offsets = vec2[aa_box8x8_samples](
	vec2(-0.4375, +0.4375), vec2(-0.3125, +0.4375), vec2(-0.1875, +0.4375), vec2(-0.0625, +0.4375), vec2(+0.0625, +0.4375), vec2(+0.1875, +0.4375), vec2(+0.3125, +0.4375), vec2(+0.4375, +0.4375),
	vec2(-0.4375, +0.3125), vec2(-0.3125, +0.3125), vec2(-0.1875, +0.3125), vec2(-0.0625, +0.3125), vec2(+0.0625, +0.3125), vec2(+0.1875, +0.3125), vec2(+0.3125, +0.3125), vec2(+0.4375, +0.3125),
	vec2(-0.4375, +0.1875), vec2(-0.3125, +0.1875), vec2(-0.1875, +0.1875), vec2(-0.0625, +0.1875), vec2(+0.0625, +0.1875), vec2(+0.1875, +0.1875), vec2(+0.3125, +0.1875), vec2(+0.4375, +0.1875),
	vec2(-0.4375, +0.0625), vec2(-0.3125, +0.0625), vec2(-0.1875, +0.0625), vec2(-0.0625, +0.0625), vec2(+0.0625, +0.0625), vec2(+0.1875, +0.0625), vec2(+0.3125, +0.0625), vec2(+0.4375, +0.0625),
	vec2(-0.4375, -0.0625), vec2(-0.3125, -0.0625), vec2(-0.1875, -0.0625), vec2(-0.0625, -0.0625), vec2(+0.0625, -0.0625), vec2(+0.1875, -0.0625), vec2(+0.3125, -0.0625), vec2(+0.4375, -0.0625),
	vec2(-0.4375, -0.1875), vec2(-0.3125, -0.1875), vec2(-0.1875, -0.1875), vec2(-0.0625, -0.1875), vec2(+0.0625, -0.1875), vec2(+0.1875, -0.1875), vec2(+0.3125, -0.1875), vec2(+0.4375, -0.1875),
	vec2(-0.4375, -0.3125), vec2(-0.3125, -0.3125), vec2(-0.1875, -0.3125), vec2(-0.0625, -0.3125), vec2(+0.0625, -0.3125), vec2(+0.1875, -0.3125), vec2(-0.3125, -0.3125), vec2(+0.4375, -0.3125),
	vec2(-0.4375, -0.4375), vec2(-0.3125, -0.4375), vec2(-0.1875, -0.4375), vec2(-0.0625, -0.4375), vec2(+0.0625, -0.4375), vec2(+0.1875, -0.4375), vec2(+0.3125, -0.4375), vec2(+0.4375, -0.4375)
);
const float[aa_box8x8_samples] aa_box8x8_weights = float[aa_box8x8_samples](
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1
);
const float aa_box8x8_gain = 0.015625;

// Rotated grid super sampling picks a useful subset of the equivalent box samples.
const uint aa_rgss2x2_samples = 4;
const vec2[aa_rgss2x2_samples] aa_rgss2x2_offsets = vec2[aa_rgss2x2_samples](

	/*vec2(-0.375, +0.375),*/ /*vec2(-0.125, +0.375),*/   vec2(+0.125, +0.375),   /*vec2(+0.375, +0.375),*/
	vec2(-0.375, +0.125),     /*vec2(-0.125, +0.125),*/ /*vec2(+0.125, +0.125),*/ /*vec2(+0.375, +0.125),*/
	/*vec2(-0.375, -0.125),*/ /*vec2(-0.125, -0.125),*/ /*vec2(+0.125, -0.125),*/   vec2(+0.375, -0.125),
	/*vec2(-0.375, -0.375),*/   vec2(-0.125, -0.375)    /*vec2(+0.125, -0.375),*/ /*vec2(+0.375, -0.375)*/
);
const float[aa_rgss2x2_samples] aa_rgss2x2_weights = float[aa_rgss2x2_samples](
	1, 1,
	1, 1
);
const float aa_rgss2x2_gain = 0.25;

// Checker super sampling picks a useful subset of the equivalent box samples.
const uint aa_checker4x4_samples = 8;
const vec2[aa_checker4x4_samples] aa_checker4x4_offsets = vec2[aa_checker4x4_samples](
	  vec2(-0.375, +0.375), /*vec2(-0.125, +0.375),*/ vec2(+0.125, +0.375), /*vec2(+0.375, +0.375),*/
	/*vec2(-0.375, +0.125),*/ vec2(-0.125, +0.125), /*vec2(+0.125, +0.125),*/ vec2(+0.375, +0.125),
	  vec2(-0.375, -0.125), /*vec2(-0.125, -0.125),*/ vec2(+0.125, -0.125), /*vec2(+0.375, -0.125),*/
	/*vec2(-0.375, -0.375),*/ vec2(-0.125, -0.375), /*vec2(+0.125, -0.375),*/ vec2(+0.375, -0.375)
);
const float[aa_checker4x4_samples] aa_checker4x4_weights = float[aa_checker4x4_samples](
	1, 1,
	1, 1,
	1, 1,
	1, 1
);
const float aa_checker4x4_gain = 0.125;

const uint aa_checker8x8_samples = 32;
const vec2[aa_checker8x8_samples] aa_checker8x8_offsets = vec2[aa_checker8x8_samples](
	  vec2(-0.4375, +0.4375), /*vec2(-0.3125, +0.4375),*/ vec2(-0.1875, +0.4375), /*vec2(-0.0625, +0.4375),*/ vec2(+0.0625, +0.4375), /*vec2(+0.1875, +0.4375),*/ vec2(+0.3125, +0.4375), /*vec2(+0.4375, +0.4375),*/
	/*vec2(-0.4375, +0.3125),*/ vec2(-0.3125, +0.3125), /*vec2(-0.1875, +0.3125),*/ vec2(-0.0625, +0.3125), /*vec2(+0.0625, +0.3125),*/ vec2(+0.1875, +0.3125), /*vec2(+0.3125, +0.3125),*/ vec2(+0.4375, +0.3125),
	  vec2(-0.4375, +0.1875), /*vec2(-0.3125, +0.1875),*/ vec2(-0.1875, +0.1875), /*vec2(-0.0625, +0.1875),*/ vec2(+0.0625, +0.1875), /*vec2(+0.1875, +0.1875),*/ vec2(+0.3125, +0.1875), /*vec2(+0.4375, +0.1875),*/
	/*vec2(-0.4375, +0.0625),*/ vec2(-0.3125, +0.0625), /*vec2(-0.1875, +0.0625),*/ vec2(-0.0625, +0.0625), /*vec2(+0.0625, +0.0625),*/ vec2(+0.1875, +0.0625), /*vec2(+0.3125, +0.0625),*/ vec2(+0.4375, +0.0625),
	  vec2(-0.4375, -0.0625), /*vec2(-0.3125, -0.0625),*/ vec2(-0.1875, -0.0625), /*vec2(-0.0625, -0.0625),*/ vec2(+0.0625, -0.0625), /*vec2(+0.1875, -0.0625),*/ vec2(+0.3125, -0.0625), /*vec2(+0.4375, -0.0625),*/
	/*vec2(-0.4375, -0.1875),*/ vec2(-0.3125, -0.1875), /*vec2(-0.1875, -0.1875),*/ vec2(-0.0625, -0.1875), /*vec2(+0.0625, -0.1875),*/ vec2(+0.1875, -0.1875), /*vec2(+0.3125, -0.1875),*/ vec2(+0.4375, -0.1875),
	  vec2(-0.4375, -0.3125), /*vec2(-0.3125, -0.3125),*/ vec2(-0.1875, -0.3125), /*vec2(-0.0625, -0.3125),*/ vec2(+0.0625, -0.3125), /*vec2(+0.1875, -0.3125),*/ vec2(-0.3125, -0.3125), /*vec2(+0.4375, -0.3125),*/
	/*vec2(-0.4375, -0.4375),*/ vec2(-0.3125, -0.4375), /*vec2(-0.1875, -0.4375),*/ vec2(-0.0625, -0.4375), /*vec2(+0.0625, -0.4375),*/ vec2(+0.1875, -0.4375), /*vec2(+0.3125, -0.4375),*/ vec2(+0.4375, -0.4375)
);
const float[aa_checker8x8_samples] aa_checker8x8_weights = float[aa_checker8x8_samples](
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1,
	1, 1, 1, 1
);
const float aa_checker8x8_gain = 0.03125;

// Equivalent to a guassian blur.
const uint aa_guassian3x3_samples = 9;
const vec2[aa_guassian3x3_samples] aa_guassian3x3_offsets = vec2[aa_guassian3x3_samples](
	vec2(-1.0/3.0, +1.0/3.0), vec2(+0.0/3.0, +1.0/3.0), vec2(+1.0/3.0, +1.0/3.0),
	vec2(-1.0/3.0, +0.0/3.0), vec2(+0.0/3.0, +0.0/3.0), vec2(+1.0/3.0, +0.0/3.0),
	vec2(-1.0/3.0, -1.0/3.0), vec2(+0.0/3.0, -1.0/3.0), vec2(+1.0/3.0, -1.0/3.0)
);
const float[aa_guassian3x3_samples] aa_guassian3x3_weights = float[aa_guassian3x3_samples](
	0.0625, 0.125, 0.0625,
	0.1250, 0.250, 0.1250,
	0.0625, 0.125, 0.0625
);
const float aa_guassian3x3_gain = 1.0;

const uint aa_guassian3x3_no_mid_samples = 8;
const vec2[aa_guassian3x3_no_mid_samples] aa_guassian3x3_no_mid_offsets = vec2[aa_guassian3x3_no_mid_samples](
	vec2(-1.0/3.0, +1.0/3.0), vec2(+0.0/3.0, +1.0/3.0), vec2(+1.0/3.0, +1.0/3.0),
	vec2(-1.0/3.0, +0.0/3.0), /*vec2(+0.0/3.0, +0.0/3.0),*/ vec2(+1.0/3.0, +0.0/3.0),
	vec2(-1.0/3.0, -1.0/3.0), vec2(+0.0/3.0, -1.0/3.0), vec2(+1.0/3.0, -1.0/3.0)
);
const float[aa_guassian3x3_no_mid_samples] aa_guassian3x3_no_mid_weights = float[aa_guassian3x3_no_mid_samples](
	0.0625, 0.125, 0.0625,
	0.1250, /*0.250,*/ 0.1250,
	0.0625, 0.125, 0.0625
);
const float aa_guassian3x3_no_mid_gain = 1.0;
const float aa_guassian3x3_no_mid_mid_gain = 0.250;

#endif

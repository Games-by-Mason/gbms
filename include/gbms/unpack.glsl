#ifndef INCLUDE_GBMS_UNPACK
#define INCLUDE_GBMS_UNPACK

ivec2 unpackShort2x16(uint n) {
	return ivec2(
		n & 0x0000FFFF,
		n >> 16
	);
}

#endif

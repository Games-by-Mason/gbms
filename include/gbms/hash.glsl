#ifndef INCLUDE_GBMS_HASH
#define INCLUDE_GBMS_HASH

// Balanced performance and quality. Good default. The 32-bit "RXS-M-XS" variant of Melissa
// O'Neill's PCG PRNG, adapted for use as a hash function.
//
// Use `floatBitsToUint(f)` to preprocess your input if it's a float or float vector.
uint hashPcg(uint i) {
    uint state = i * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

uint hashPcg(uvec2 i) {
    return hashPcg(hashPcg(i.x) + i.y);
}

uint hashPcg(uvec3 i) {
    return hashPcg(hashPcg(hashPcg(i.x) + i.y) + i.z);
}

uint hashPcg(uvec4 i) {
    return hashPcg(hashPcg(hashPcg(hashPcg(i.x) + i.y) + i.z) + i.w);
}

#endif

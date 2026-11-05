#ifndef d_shader_utils_float
#define d_shader_utils_float

float decodeColor(vec4 color) {
    uvec4 iColor = uvec4(round(color * 255.));
    return uintBitsToFloat(iColor.x << 24 | iColor.y << 16 | iColor.z << 8 | iColor.w);
}

vec4 encodeFloat(float x) {
    return vec4(uvec4(floatBitsToUint(x)) >> uvec4(24, 16, 8, 0) & uvec4(255)) / 255.;
}

float floatFetch(sampler2D Sampler, ivec2 coords) {
    return decodeColor(texelFetch(Sampler, coords, 0));
}

#endif

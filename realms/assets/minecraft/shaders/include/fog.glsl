#ifndef MINECRAFT_FOG_GLSL
#define MINECRAFT_FOG_GLSL

// CUSTOM CODE
// Preprocessor macro to rename the UBO member and avoid identifier collision
#define FogColor u_NativeFogColor
layout(std140) uniform Fog {
    vec4 u_NativeFogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};
#undef FogColor

// Dynamic fog remapping logic
vec4 get_custom_fog_color() {
    const vec3 PLAINS_FOG       = vec3(192/255., 216/255., 255/255.); // #C0D8FF
    const vec3 MUSEUM_FOG       = vec3(144/255., 199/255., 166/255.); // #90C7A6
    const vec3 MUSEUM_WATER_FOG = vec3( 25/255., 139/255., 143/255.); // #198B8F
    const vec3 PLAINS_WATER_FOG = vec3(  5/255.,   5/255.,  51/255.); // #050533

    float maxComponent = max(u_NativeFogColor.r, max(u_NativeFogColor.g, u_NativeFogColor.b));
    if (maxComponent < 0.001) {
        return u_NativeFogColor;
    }

    vec3 currentNormalized = u_NativeFogColor.rgb / maxComponent;

    vec3 defaultWaterNorm = PLAINS_WATER_FOG / max(PLAINS_WATER_FOG.r, max(PLAINS_WATER_FOG.g, PLAINS_WATER_FOG.b));
    if (distance(currentNormalized, defaultWaterNorm) < 0.08) {
        // Preserves underwater depth darkening and light levels
        vec3 atmosphericFactor = u_NativeFogColor.rgb / PLAINS_WATER_FOG;
        return vec4(MUSEUM_WATER_FOG * 0.325 * atmosphericFactor, u_NativeFogColor.a);
    }

    vec3 atmosphericFactor = u_NativeFogColor.rgb / PLAINS_FOG;
    return vec4(MUSEUM_FOG * atmosphericFactor, u_NativeFogColor.a);
}

// Override FogColor globally for all shader files including this header
#define FogColor get_custom_fog_color()
// END CUSTOM CODE

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd), linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd));
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmantalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float fog_spherical_distance(vec3 pos) {
    return length(pos);
}

float fog_cylindrical_distance(vec3 pos) {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
}

#endif
#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>
#include <minecraft:terrainglobals.glsl>
#ifndef MULTIDRAW_TERRAIN
    #include <minecraft:chunksection.glsl>
#endif

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 3) in ivec2 UV2;
#ifdef MULTIDRAW_TERRAIN
layout(location = 4) in ivec3 ChunkPosition;
layout(location = 5) in float ChunkVisibility;
#endif

#ifndef OIT_ALPHA_ONLY
uniform sampler2D Sampler2;
#endif

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;
layout(location = 4) out float chunkVisibility;

void main() {
    vec3 pos = Position + (ChunkPosition - CameraBlockPos) + CameraOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);

    // CUSTOM CODE
    const vec3 PLAINS_GRASS   = vec3(145/255., 189/255.,  89/255.); // #91bd59
    const vec3 MUSEUM_GRASS   = vec3(107/255., 187/255.,  62/255.); // #6bbb3e
    const vec3 PLAINS_FOLIAGE = vec3(119/255., 171/255.,  47/255.); // #77ab2f
    const vec3 MUSEUM_FOLIAGE = vec3(90/255.,  161/255.,  58/255.); // #5aa13a
    const vec3 PLAINS_WATER   = vec3(63/255.,  118/255., 228/255.); // #3f76e4
    const vec3 MUSEUM_WATER   = vec3(41/255.,  192/255., 222/255.); // #29c0de

    // Apply custom biome colors for non-experimental worlds
    vec4 customColor = Color;
    if (distance(customColor.rgb, PLAINS_GRASS) < 0.01) {
        customColor.rgb = MUSEUM_GRASS;
    }
    else if (distance(customColor.rgb, PLAINS_FOLIAGE) < 0.01) {
        customColor.rgb = MUSEUM_FOLIAGE;
    }
    else if (distance(customColor.rgb, PLAINS_WATER) < 0.01) {
        customColor.rgb = MUSEUM_WATER;
    }
    else if (distance(customColor.rgb, PLAINS_WATER * 0.8) < 0.01) {
        customColor.rgb = MUSEUM_WATER * 0.8;
    }
    else if (distance(customColor.rgb, PLAINS_WATER * 0.6) < 0.01) {
        customColor.rgb = MUSEUM_WATER * 0.6;
    }

    #ifndef OIT_ALPHA_ONLY
    vertexColor = customColor * sample_lightmap(Sampler2, UV2);
    #else
    vertexColor = customColor;
    // END CUSTOM CODE
    #endif
    texCoord0 = UV0;

    const float chunkFullyVisibleRange = 16.0;
    float dist = length(pos);
    chunkVisibility = mix(1.0, ChunkVisibility, clamp((dist - chunkFullyVisibleRange) / chunkFullyVisibleRange, 0.0, 1.0));
}
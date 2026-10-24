#version 330
#extension GL_ARB_separate_shader_objects : require

#include <sodium:globals.glsl>
#include <sodium:fog.glsl>
#include <sodium:chunk_vertex.glsl>

layout(location = 0) out vec4 v_Color;
layout(location = 1) out vec2 v_TexCoord;

#ifdef USE_FOG
layout(location = 2) out vec2 v_FragDistance;
layout(location = 3) out float fadeFactor;
#endif

uniform isamplerBuffer u_SectionTimeInfo;

#ifdef VULKAN
layout(push_constant) uniform PC {
    vec3 u_RegionOffset;
    int u_CurrentTime;
    uint u_RegionID;
};
#else
uniform vec3 u_RegionOffset;
uniform int u_CurrentTime;
uniform uint u_RegionID;
#endif

#ifndef OIT_ALPHA_ONLY
uniform sampler2D u_LightTex; // The light map texture sampler
#endif

uvec3 _get_relative_chunk_coord(uint pos) {
    // Packing scheme is defined by LocalSectionIndex
    return uvec3(pos) >> uvec3(5u, 0u, 2u) & uvec3(7u, 3u, 7u);
}

vec3 _get_draw_translation(uint pos) {
    return _get_relative_chunk_coord(pos) * vec3(16.0);
}

void main() {
    _vert_init();

    // Transform the chunk-local vertex position into world model space
    vec3 translation = u_RegionOffset + _get_draw_translation(_draw_id);
    vec3 position = _vert_position + translation;

#ifdef USE_FOG
    v_FragDistance = getFragDistance(position);

    int chunkId = int(_draw_id);
    int chunkFade = texelFetch(u_SectionTimeInfo, int((u_RegionID * 256u) + uint(chunkId))).r;
    int fadeTime = u_CurrentTime - chunkFade;
    float elapsed = float(fadeTime);
    float fade = clamp(float(u_CurrentTime - chunkFade) * u_FadePeriodInv, 0.0, 1.0);
    fadeFactor = (chunkFade < 0) ? 1.0 : fade;
#endif

    // Transform the vertex position into model-view-projection space
    gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * vec4(position, 1.0);

    // CUSTOM CODE
    const vec3 PLAINS_GRASS   = vec3(145/255., 189/255.,  89/255.); // #91bd59
    const vec3 MUSEUM_GRASS   = vec3(107/255., 187/255.,  62/255.); // #6bbb3e
    const vec3 PLAINS_FOLIAGE = vec3(119/255., 171/255.,  47/255.); // #77ab2f
    const vec3 MUSEUM_FOLIAGE = vec3( 90/255., 161/255.,  58/255.); // #5aa13a
    const vec3 PLAINS_WATER   = vec3( 63/255., 118/255., 228/255.); // #3f76e4
    const vec3 MUSEUM_WATER   = vec3( 41/255., 192/255., 222/255.); // #29c0de
    
    // Apply custom biome colors for non-experimental worlds
    vec4 customColor = _vert_color;

    // Check chromaticity (direction) to ignore AO brightness variations
    vec3 normCurrent = normalize(customColor.rgb + vec3(1e-5));
    float grassDist   = distance(normCurrent, normalize(PLAINS_GRASS));
    float foliageDist = distance(normCurrent, normalize(PLAINS_FOLIAGE));
    float waterDist   = distance(normCurrent, normalize(PLAINS_WATER));

    if (grassDist < 0.05) {
        float intensity = dot(customColor.rgb, PLAINS_GRASS) / dot(PLAINS_GRASS, PLAINS_GRASS);
        customColor.rgb = MUSEUM_GRASS * clamp(intensity, 0.0, 1.0);
    }
    else if (foliageDist < 0.05) {
        float intensity = dot(customColor.rgb, PLAINS_FOLIAGE) / dot(PLAINS_FOLIAGE, PLAINS_FOLIAGE);
        customColor.rgb = MUSEUM_FOLIAGE * clamp(intensity, 0.0, 1.0);
    }
    else if (waterDist < 0.05) {
        float intensity = dot(customColor.rgb, PLAINS_WATER) / dot(PLAINS_WATER, PLAINS_WATER);
        customColor.rgb = MUSEUM_WATER * clamp(intensity, 0.0, 1.0);
    }

    // Add the light color to the vertex color, and pass the texture coordinates to the fragment shader
#ifndef OIT_ALPHA_ONLY
    v_Color = customColor * texture(u_LightTex, _vert_tex_light_coord);
#else
    v_Color = customColor;
#endif
    // END CUSTOM CODE

    v_TexCoord = (_vert_tex_diffuse_coord_bias * u_TexCoordShrink) + _vert_tex_diffuse_coord; // FMA for precision
}

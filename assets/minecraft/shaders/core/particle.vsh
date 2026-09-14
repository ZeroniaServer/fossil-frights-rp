#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>

// CUSTOM CODE
#include <minecraft:emissive_utils.glsl>
// END CUSTOM CODE

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;
layout(location = 2) in vec4 Color;
layout(location = 3) in ivec2 UV2;

uniform sampler2D Sampler2;

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) out vec2 texCoord0;
layout(location = 3) out vec4 vertexColor;

// CUSTOM CODE
layout(location = 4) out vec4 lightMapColor;
layout(location = 5) out vec4 maxLightMapColor;
// END CUSTOM CODE

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    texCoord0 = UV0;

    // CUSTOM CODE
    vertexColor = Color;
    lightMapColor = sample_lightmap(Sampler2, UV2);
    maxLightMapColor = sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    // END CUSTOM CODE
}
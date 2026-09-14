#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

// CUSTOM CODE
#include <minecraft:emissive_utils.glsl>
// END CUSTOM CODE

uniform sampler2D Sampler0;

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
layout(location = 2) in vec2 texCoord0;
layout(location = 3) in vec4 vertexColor;

// CUSTOM CODE
layout(location = 4) in vec4 lightMapColor;
layout(location = 5) in vec4 maxLightMapColor;
// END CUSTOM CODE

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif
    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;

    // CUSTOM CODE
    // Discards vertexColor (tint) on obsidian tear particles
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    if (check_alpha(alpha, 250.0)) {
        color = texture(Sampler0, texCoord0) * ColorModulator;
        color.a = 1;
    }
    // Multiplies color for antigravity particles
    else if (check_alpha(alpha, 249.0)) {
        vec4 antiGravityColor = vec4(66/255., 29/255., 208/255., 1);
        color = texture(Sampler0, texCoord0) * antiGravityColor * mix(lightMapColor, maxLightMapColor, 0.5) * ColorModulator;
        color.a = 1;
    }
    // END CUSTOM CODE

    if (color.a < 0.1) {
        discard;
    }
    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
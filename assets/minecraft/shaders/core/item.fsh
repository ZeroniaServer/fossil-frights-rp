#version 330
#extension GL_ARB_separate_shader_objects : require

#ifdef GLINT
#include <minecraft:globals.glsl>
#endif
#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>

// CUSTOM CODE
#include <minecraft:emissive_utils.glsl>

// FOG
#include <d_shader_utils:float.glsl>
#include <minecraft:projection.glsl>

// END CUSTOM CODE

uniform sampler2D Sampler0;

#ifdef GLINT
uniform sampler2D GlintSampler;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
#endif
layout(location = 2) in vec4 vertexColor;
// CUSTOM CODE
layout(location = 8) in vec4 diffuseColor;
// END CUSTOM CODE
#ifndef OIT_ALPHA_ONLY
layout(location = 3) in vec4 lightMapColor;
layout(location = 4) in vec4 overlayColor;
#endif
layout(location = 5) in vec2 texCoord0;
#ifdef GLINT
layout(location = 6) in vec2 texCoordGlint;
#endif
// CUSTOM CODE -- FOG
layout(location = 7) flat in int markerType;
// END CUSTOM CODE

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

// CUSTOM CODE
const vec3 AURORA_MARKER = vec3(254/255., 255/255., 254/255.);
// END CUSTOM CODE

#ifndef OIT_ALPHA_ONLY
vec4 calculateFinalColor(vec4 color) {
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);

    // CUSTOM CODE
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    if (!check_alpha(alpha, 250.0) && distance(diffuseColor.rgb, AURORA_MARKER) > 0.005) {
        color *= lightMapColor;
    }
    // END CUSTOM CODE

    #ifdef GLINT
    vec4 glintColor = GlintAlpha * texture(GlintSampler, texCoordGlint);// Glint color modulator?
    // Matches BlendFuntion.GLINT
    color.rgb += glintColor.rgb * glintColor.rgb;
    #endif

    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}
#endif

void main() {
    // CUSTOM CODE -- FOG
    int x = int(gl_FragCoord.x);
    int y = int(gl_FragCoord.y);
    if (x == 0 && (y == 0 || y == 1))
    {
        #ifndef OIT_ALPHA_ONLY
        if (markerType == 2)
        {
            float ProjMatY = ProjMat[1][1];
            if (y == 0) {
                fragColor = vec4(encodeFloat(ProjMatY).rgb, 1);
            } else if (y == 1) {
                fragColor = vec4(encodeFloat(ProjMatY).a, 0, 0, 1);
            } else {
                discard;
            }
            return;
        }
        #endif
        discard;
    }
    if (markerType != -1) discard;
    // END CUSTOM CODE

    vec4 color = texture(Sampler0, texCoord0);
    #ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
    #endif

    // CUSTOM CODE
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    if (!check_alpha(alpha, 250.0) && distance(diffuseColor.rgb, AURORA_MARKER) > 0.005) {
        color *= vertexColor;
    } else if (distance(diffuseColor.rgb, AURORA_MARKER) > 0.005) {
        color *= diffuseColor;
        color.a = 1.0;
    }
    color *= ColorModulator;
    // END CUSTOM CODE

    #ifdef GLINT
    color.a = max(color.a, GlintAlpha);
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
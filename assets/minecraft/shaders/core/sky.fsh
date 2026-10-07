#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;

layout(location = 0) out vec4 fragColor;

void main() {
    // CUSTOM CODE
    vec4 customSkyColor = ColorModulator;
    const vec3 PLAINS_SKY = vec3(120/255., 167/255., 255/255.); // #78A7FF
    const vec3 MUSEUM_SKY = vec3(126/255., 222/255., 255/255.); // #7EDEFF

    float maxComponent = max(ColorModulator.r, max(ColorModulator.g, ColorModulator.b));
    vec3 currentNormalized = ColorModulator.rgb / maxComponent;

    vec3 defaultSkyNorm = PLAINS_SKY / max(PLAINS_SKY.r, max(PLAINS_SKY.g, PLAINS_SKY.b));
    if (distance(currentNormalized, defaultSkyNorm) < 0.08) {
        vec3 atmosphericFactor = ColorModulator.rgb / PLAINS_SKY;
        customSkyColor = vec4(MUSEUM_SKY * atmosphericFactor, ColorModulator.a);
    }
    // END CUSTOM CODE

    fragColor = apply_fog(customSkyColor, sphericalVertexDistance, cylindricalVertexDistance, 0.0, FogSkyEnd, FogSkyEnd, FogSkyEnd, FogColor);
}
#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:globals.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
// CUSTOM CODE
layout(location = 2) in mat4 ProjInv;

layout(location = 0) out vec4 fragColor;

void main() {
    vec4 customSkyColor = ColorModulator;
    const vec3 PLAINS_SKY = vec3(120/255., 167/255., 255/255.); // #78A7FF
    const vec3 MUSEUM_SKY = vec3(126/255., 222/255., 255/255.); // #7EDEFF
    vec3 atmosphericFactor = ColorModulator.rgb / PLAINS_SKY;
    customSkyColor = vec4(MUSEUM_SKY * atmosphericFactor, ColorModulator.a);

    vec4 screenPos = gl_FragCoord;
    screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
    screenPos.z = 0.0; // far plane in reverse-Z
    screenPos.w = 1.0;
    vec3 view = normalize((ProjInv * screenPos).xyz);
    float ndusq = clamp(view.y, -1.0, 1.0);
    float fogFactor = smoothstep(0.1, 0.0, ndusq);
    fragColor = apply_fog(customSkyColor, fogFactor, fogFactor, 0.0, 1.0, 0.0, 1.0, FogColor);
}
// END CUSTOM CODE
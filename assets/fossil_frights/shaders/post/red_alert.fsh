#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform AlertData {
    float Offset;
};

#include <minecraft:globals.glsl>

layout (location = 0) in vec2 texCoord;

float Frequency = 1/20.;
float Intensity = 0.7;

layout (location = 0) out vec4 fragColor;

void main() {
    fragColor = texture(MainSampler, texCoord);

    // Color Matrix
    vec3 RedMatrix = vec3(1, 0.0, 0.0);
    float RedValue = dot(fragColor.rgb, RedMatrix);
    vec4 OutColor = vec4(RedValue, 0, 0, 1.0);

    // Pulse Color Output
    float pulse = (cos((GameTime * 24000 + Offset) * Frequency * 3.1415926535)) / 2 + 0.5;
    OutColor.rgb = mix(fragColor.rgb, OutColor.rgb, (1-pulse) * Intensity);

    fragColor = OutColor;
}
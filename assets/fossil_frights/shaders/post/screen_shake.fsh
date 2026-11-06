#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout (location = 0) in vec2 texCoord;
layout (location = 1) flat in float fade;

layout (location = 0) out vec4 fragColor;

#define FREQUENCY 100000.0

void main() {
    float intensity = clamp(fade, 0.0, 1.25);

    if (intensity <= 0.0) {
        fragColor = texture(MainSampler, texCoord);
        return;
    }

    vec2 magnitude = vec2(intensity / 200.);
    vec2 freq = vec2(FREQUENCY);

    vec2 uv = texCoord;
    
    // Zoom in to prevent black bars
    uv -= 0.5;
    uv *= 1.0 - 2.0 * magnitude.x;
    uv += 0.5;

    uv.x += sin(GameTime * freq.x) * magnitude.x;
    uv.y += cos(GameTime * freq.y) * magnitude.y;

    fragColor = texture(MainSampler, uv);
}
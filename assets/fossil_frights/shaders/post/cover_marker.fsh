#version 330
#extension GL_ARB_separate_shader_objects : require

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

uniform sampler2D InSampler;

#include <minecraft:globals.glsl>

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = texture(InSampler, texCoord);
    int x = int(gl_FragCoord.x);
    int y = int(gl_FragCoord.y);
    if (y == 0) {
        if (x == ScreenSize.x/2) {
            fragColor = texelFetch(InSampler, ivec2(ScreenSize.x/2-1, 0), 0);
        } else if (x == ScreenSize.x/2+1) {
            fragColor = texelFetch(InSampler, ivec2(ScreenSize.x/2+2, 0), 0);
        }
    }
}
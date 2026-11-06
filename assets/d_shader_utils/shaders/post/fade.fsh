#version 330
#extension GL_ARB_separate_shader_objects : require

#include <d_shader_utils:float.glsl>
#include <minecraft:globals.glsl>

uniform sampler2D InSampler;

layout(std140) uniform FadeConfig {
    float Initial;
    float Rate;
};

layout(location = 0) out vec4 fragColor;

void main() {
    bool isFirstFrame = texelFetch(InSampler, ivec2(2, 0), 0) != vec4(1.0, 1.0, 1.0, 1.0);
    float deltaTime = isFirstFrame ? 0.0 : fract(GameTime - floatFetch(InSampler, ivec2(1, 0))) * 1200.0;
    switch (int(gl_FragCoord.x)) {
        case 0:
            float x = isFirstFrame ? Initial : floatFetch(InSampler, ivec2(0, 0)) + Rate * deltaTime;
            fragColor = encodeFloat(x);
            break;
        case 1:
            fragColor = encodeFloat(GameTime);
            break;
        case 2:
            // Should be different from buffer's default color (black)
            fragColor = vec4(1.0, 1.0, 1.0, 1.0);
            break;
        default:
            fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
#version 330
#extension GL_ARB_separate_shader_objects : require

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform DesaturateConfig {
    float MaxIntensity;
};

layout (location = 0) in vec2 texCoord;
layout (location = 1) flat in float fade;

layout (location = 0) out vec4 fragColor;

void main() {
    fragColor = texture(MainSampler, texCoord);
    float intensity = clamp(fade, 0.0, 1.0);
    if (intensity <= 0.0) {
        return;
    }
    vec3 grayscale = vec3(dot(fragColor.rgb, vec3(0.2126, 0.7152, 0.0722)));
    fragColor.rgb = mix(fragColor.rgb, grayscale, intensity * MaxIntensity);
}
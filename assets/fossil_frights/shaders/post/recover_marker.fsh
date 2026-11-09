#version 330
#extension GL_ARB_separate_shader_objects : require

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

uniform sampler2D InSampler;
uniform sampler2D MainSampler;

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = texture(InSampler, texCoord);
    int x = int(gl_FragCoord.x);
    int y = int(gl_FragCoord.y);
    if (x == 0 && (y == 0 || y == 1)) {
        fragColor = texture(MainSampler, texCoord);
    }
}
#version 330
#extension GL_ARB_separate_shader_objects : require

#include <d_shader_utils:fog.glsl>
#include <d_shader_utils:float.glsl>
#include <minecraft:globals.glsl>

uniform sampler2D InSampler;
uniform sampler2D MainDepthSampler;

layout(location = 0) in vec2 texCoord;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform FogConfig {
    vec4 FogColor;
    float FogStartDepth;
    float FogEndDepth;
};

layout(location = 0) out vec4 fragColor;

void main(){ 
    // Sample Inputs
    fragColor = texture(InSampler, texCoord);
    
    vec3 data1 = texelFetch(InSampler, ivec2(0, 0), 0).rgb;
    vec3 data2 = texelFetch(InSampler, ivec2(0, 1), 0).rgb;
    float ProjMatY = decodeColor(vec4(data1.rgb, data2.r));
    
    // Mix depth
    float BlockDepth = LinearizeDepth(texture(MainDepthSampler, texCoord).r);
    float BlockDistance = length(vec3(1., (2.*texCoord - 1.) * vec2(ScreenSize.x/ScreenSize.y,1.) / ProjMatY) * BlockDepth);

    if (BlockDistance > FogStartDepth && BlockDistance < FogEndDepth) {
        // Is within fog draw range
        float FogFadeLength = float( FogEndDepth - FogStartDepth );
        float FogIntensity = float( ( BlockDistance - FogStartDepth) / FogFadeLength);
        fragColor = mix(fragColor, FogColor, FogIntensity * FogColor.a);
    } else if (BlockDistance >= FogEndDepth) {
        fragColor = mix(fragColor, FogColor, FogColor.a);
    }
}
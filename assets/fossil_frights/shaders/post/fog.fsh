#version 330
#extension GL_ARB_separate_shader_objects : require

#include <d_shader_utils:fog.glsl>
#include <minecraft:globals.glsl>

uniform sampler2D InSampler;
uniform sampler2D FogDataSampler;
uniform sampler2D DataSampler;
uniform sampler2D MainDepthSampler;

layout(location = 0) in vec2 texCoord;

#include <shader_selector:marker_settings.glsl>
#include <shader_selector:utils.glsl>
#include <shader_selector:data_reader.glsl>

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(std140) uniform FogConfig {
    vec4 FogColor;
    float FogStartDepth;
    float FogEndDepth;
    int Channel;
};

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = texture(InSampler, texCoord);
    float intensity = readChannel(Channel);
    if (intensity <= 0.0) {
        return;
    }

    // Sample Inputs
    vec3 data1 = texelFetch(FogDataSampler, ivec2(ScreenSize.x/2, 0), 0).rgb;
    vec3 data2 = texelFetch(FogDataSampler, ivec2(ScreenSize.x/2+1, 1), 0).rgb;
    float ProjMatY = decodeColor(vec4(data1.rgb, data2.r));
    
    // Mix depth
    float BlockDepth = LinearizeDepth(texture(MainDepthSampler, texCoord).r);
    float BlockDistance = length(vec3(1., (2.*texCoord - 1.) * vec2(ScreenSize.x/ScreenSize.y,1.) / ProjMatY) * BlockDepth);

    // Interpolate start/end distance based on fade parameter
    float fadeFogStartDepth = mix(FogStartDepth + 100, FogStartDepth, 1 - pow(1 - intensity, 3));
    float fadeFogEndDepth = mix(FogEndDepth + 100, FogEndDepth, 1 - pow(1 - intensity, 3));

    if (BlockDistance > fadeFogStartDepth && BlockDistance < fadeFogEndDepth) {
        // Is within fog draw range
        float FogFadeLength = float( fadeFogEndDepth - fadeFogStartDepth );
        float FogIntensity = float( ( BlockDistance - fadeFogStartDepth) / FogFadeLength);
        fragColor = mix(fragColor, FogColor, FogIntensity * FogColor.a * intensity);
    } else if (BlockDistance >= fadeFogEndDepth) {
        fragColor = mix(fragColor, FogColor, FogColor.a * intensity);
    }

    if (Channel == CHIMNEY_SMOKE_CHANNEL)
    {
        vec3 grayscale = vec3(dot(fragColor.rgb, vec3(0.2126, 0.7152, 0.0722)));
        fragColor.rgb = mix(fragColor.rgb, grayscale, intensity * 0.75);
    }

    // #define DEBUG
#ifdef DEBUG
    // Show data sampler on screen
    if (texCoord.x < .25 && texCoord.y < .25) {
        vec2 uv = texCoord * 4.0;
        vec4 col = texture(DataSampler, uv);
        if (uv.x > 1./5.)
            col = vec4(vec3(fract(decodeColor(col))), 1.0);
        fragColor = col;
    }
#endif
}
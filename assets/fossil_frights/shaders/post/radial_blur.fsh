#version 330
#extension GL_ARB_separate_shader_objects : require


uniform sampler2D InSampler;

layout (location = 0) in vec2 texCoord;
layout (location = 1) flat in float fade;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

#include <minecraft:globals.glsl> // Using GlintAlpha as a setting for controlling distortion

layout (location = 0) out vec4 fragColor;

const float BLUR_STRENGTH   = 0.045; // Max radial streak length at the corners
const float BLUR_START      = 0.30;  // Radius where blur begins (keeps center subject sharp)
const float BLUR_END        = 1.55;  // Radius where blur reaches full intensity

const float VIG_OPACITY     = 0.16;  // Subtle white corner haze (0.12 - 0.22 matches the frame)
const float VIG_START       = 0.45;  // Where the white vignette begins fading in
const float VIG_END         = 1.55;  // Where the white vignette reaches VIG_OPACITY
const float VIG_ROUNDNESS   = 0.25;  // 0.0 = matches screen aspect ratio, 1.0 = circular

const int   BLUR_SAMPLES    = 32;    // Smooth radial streak quality

// Interleaved Gradient Noise to eliminate sample stepping
float gradientNoise(vec2 uv) {
    return fract(52.9829189 * fract(dot(uv, vec2(0.06711056, 0.00583715))));
}

// Screen blend mode: 1 - (1 - Base) * (1 - Blend)
vec3 blendScreen(vec3 base, vec3 blend) {
    return 1.0 - (1.0 - base) * (1.0 - blend);
}

void main() {
    float intensity = clamp(fade, 0.0, 1.0);
    if (intensity <= 0.0) {
        fragColor = texture(InSampler, texCoord);
        return;
    }

    // Aspect-aware distance from center
    float aspect = OutSize.x / OutSize.y;
    vec2 toCenter = texCoord - 0.5;
    vec2 vigCoord = toCenter;
    vigCoord.x *= mix(1.0, aspect, VIG_ROUNDNESS);
    float dist = length(vigCoord) * 2.0; // ~0.0 at center, ~1.0 at top/bottom, ~1.55 at corners

    // Progressive radial zoom blur
    float blurAmount = smoothstep(BLUR_START, BLUR_END, dist) * BLUR_STRENGTH * intensity * GlintAlpha;
    vec3 col = vec3(0.0);

    if (blurAmount <= 0.0001) {
        col = texture(InSampler, texCoord).rgb;
    } else {
        float jitter = gradientNoise(gl_FragCoord.xy);
        for (int i = 0; i < BLUR_SAMPLES; i++) {
            // Sample symmetrically inward and outward along the radial ray
            float t = ((float(i) + jitter) / float(BLUR_SAMPLES)) - 0.5;
            vec2 sampleUV = clamp(texCoord + toCenter * t * blurAmount, 0.001, 0.999);
            col += texture(InSampler, sampleUV).rgb;
        }
        col /= float(BLUR_SAMPLES);
    }

    // Subtle white vignette with screen blend mode
    float vigMask = smoothstep(VIG_START, VIG_END, dist);
    vec3 whiteVignette = vec3(vigMask * VIG_OPACITY * intensity);
    col = blendScreen(col, whiteVignette);

    fragColor = vec4(col, 1.0);
}
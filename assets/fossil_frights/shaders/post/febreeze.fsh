#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

uniform sampler2D MainSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

#define SPEED 0.25

// Spray coverage
#define FILM_SCALE 5.0
#define WARP_STRENGTH 1.0

// White aerosol droplets
#define SPECK_SCALE 50.0
#define SPECK_DENSITY 0.90
#define SPECK_SOFTNESS 1.0
#define SPECK_OPACITY 0.15

// Appearance
#define DISTORTION 0.1
#define BLUR 0.05
#define HAZE 0.2
#define WHITENESS 0.2
#define HIGHLIGHT 0.1

layout (location = 0) in vec2 texCoord;
layout (location = 1) flat in float fade;

layout (location = 0) out vec4 fragColor;

// --------------------------------------------------
// Hash functions
// --------------------------------------------------

float hash21(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

// --------------------------------------------------
// Smooth noise
// --------------------------------------------------

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

float fbm(vec2 p)
{
    float v = 0.0;

    v += 0.5 * noise(p);
    p = p * 2.03 + vec2(17.1, 9.2);

    v += 0.25 * noise(p);
    p = p * 2.03 + vec2(17.1, 9.2);

    v += 0.125 * noise(p);

    return v;
}

// --------------------------------------------------
// Soft aerosol specks
// --------------------------------------------------

float specks(vec2 p, float t) {
    vec2 cell = floor(p);
    vec2 local = fract(p);

    float result = 0.0;

    // Check neighbouring cells so droplets
    // aren't cut off at cell boundaries.
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 id = cell + offset;

            vec2 rnd = hash22(id);

            // Randomly decide whether this cell
            // contains a droplet.
            float visible = step(
                1.0 - SPECK_DENSITY,
                hash21(id + 13.7)
            );

            // Random droplet position
            vec2 centre = offset + rnd;

            // Gentle drifting
            centre += vec2(
                sin(t * 0.6 + rnd.x * 6.28) * 0.08,
                -sin(t * 0.4 + rnd.y * 6.28) * 0.08
            );

            // Variable droplet size
            float radius = mix(
                0.12,
                0.42,
                hash21(id + 7.3)
            );

            float d = length(local - centre);

            // Soft, blurry circular droplet
            float droplet = 1.0 - smoothstep(
                radius * (1.0 - SPECK_SOFTNESS),
                radius * (1.0 + SPECK_SOFTNESS),
                d
            );

            result = max(
                result,
                droplet * visible
            );
        }
    }

    return result;
}

// --------------------------------------------------
// Main shader
// --------------------------------------------------

void main() {
    float intensity = clamp(fade, 0.0, 1.0);

    if (intensity <= 0.0) {
        fragColor = texture(MainSampler, texCoord);
        return;
    }

    float aspect = ScreenSize.x / ScreenSize.y;
    float t = GameTime * 1200. * SPEED;

    vec2 p = texCoord * FILM_SCALE;
    p.x *= aspect;

    // --------------------------------------------------
    // Flowing aerosol film
    // --------------------------------------------------

    vec2 flow = vec2(
        fbm(p * 0.8 + vec2(t * 0.13, -t * 0.2)),
        fbm(p * 0.8 + vec2(8.7, -t * 0.25))
    ) - 0.44;

    vec2 warped = p + flow * WARP_STRENGTH;

    float film = fbm(
        warped + vec2(t * 0.1, -t * 0.18)
    );

    float coverage = smoothstep(
        0.20, 0.62, film
    );

    // --------------------------------------------------
    // Aerosol droplets
    // --------------------------------------------------

    vec2 speckUV = texCoord * SPECK_SCALE;
    speckUV.x *= aspect;

    float droplets = specks(speckUV, t);

    // Smaller, finer droplets
    float fineDroplets = specks(
        speckUV * 2.3 + vec2(17.3, 9.1),
        t * 1.4
    );

    float aerosol = max(
        droplets,
        fineDroplets * 0.45
    );

    aerosol *= SPECK_OPACITY * intensity;

    // --------------------------------------------------
    // Refraction
    // --------------------------------------------------

    vec2 displacement = flow * DISTORTION;

    displacement *= coverage * intensity;

    vec2 refractedUV = clamp(
        texCoord + displacement, 0.0, 1.0
    );

    // --------------------------------------------------
    // Base colour
    // --------------------------------------------------

    vec3 color = texture(
        MainSampler, refractedUV
    ).rgb;

    // --------------------------------------------------
    // Soft blur
    // --------------------------------------------------

    float blurAmount = BLUR * coverage * intensity;

    vec2 offset = vec2(
        blurAmount,
        blurAmount * aspect
    );

    vec3 blurred = (
        texture(MainSampler, clamp(refractedUV + offset, 0.0, 1.0)).rgb +
        texture(MainSampler, clamp(refractedUV - offset, 0.0, 1.0)).rgb +
        texture(MainSampler, clamp(refractedUV + offset * vec2(1.0, -1.0), 0.0, 1.0)).rgb +
        texture(MainSampler, clamp(refractedUV + offset * vec2(-1.0, 1.0), 0.0, 1.0)).rgb
    ) * 0.25;

    color = mix(
        color,
        blurred,
        coverage * intensity * 0.9
    );

    // --------------------------------------------------
    // Pale white haze
    // --------------------------------------------------

    vec3 hazeColor = vec3(0.93, 0.95, 0.97);

    float hazeAmount = (
        HAZE * coverage + WHITENESS
    ) * intensity;

    color = mix(
        color,
        hazeColor,
        clamp(hazeAmount, 0.0, 1.0)
    );

    // --------------------------------------------------
    // White blurry droplets
    // --------------------------------------------------

    vec3 dropletColor = vec3(0.98, 0.99, 1.0);

    color = mix(
        color,
        dropletColor,
        aerosol
    );

    // --------------------------------------------------
    // Subtle wet highlights
    // --------------------------------------------------

    float highlights = smoothstep(
        0.45, 0.7, film
    );

    color += vec3(0.8, 0.85, 0.9)
        * highlights * HIGHLIGHT
        * intensity;

    fragColor = vec4(color, 1.0);
}
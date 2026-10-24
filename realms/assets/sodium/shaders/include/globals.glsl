// CUSTOM CODE
// Preprocessor macro to rename the UBO member and avoid identifier collision
#define u_FogColor u_NativeFogColor
// END CUSTOM CODE

layout(std140) uniform u_Globals {
    mat4 u_ProjectionMatrix;
    mat4 u_ModelViewMatrix;

    vec4 u_NativeFogColor; // CUSTOM CODE
    vec2 u_EnvironmentFog;
    vec2 u_RenderFog;

    vec2 u_TexelSize;
    vec2 u_TexCoordShrink;

    float u_FadePeriodInv;
    bool u_UseRGSS;
};

// CUSTOM CODE
#undef u_FogColor

// Dynamic, continuous fog remapping logic for Plains/Void worlds
vec4 get_custom_fog_color() {
    const vec3 MUSEUM_FOG       = vec3(144/255., 199/255.,  166/255.); // #90C7A6
    const vec3 MUSEUM_WATER_FOG = vec3( 25/255., 139/255.,  143/255.); // #198B8F

    float lum = dot(u_NativeFogColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    if (lum < 0.001) {
        return u_NativeFogColor;
    }

    // Continuously calculate a water transition factor based on brightness (luminance) 
    // and blue dominance. Because this uses continuous math rather than an 'if' threshold, 
    // it begins shifting on frame 1 of entering water with zero delay.
    float blueDominance = u_NativeFogColor.b - max(u_NativeFogColor.r, u_NativeFogColor.g);
    float waterFactor = clamp((blueDominance * 2.0) + (0.3 - lum), 0.0, 1.0);

    // Scale custom colors relative to native lighting/time-of-day brightness
    vec3 airResult = MUSEUM_FOG * (lum / 0.85);
    vec3 waterResult = MUSEUM_WATER_FOG * (lum / 0.12); // Preserves depth darkening

    // Blend smoothly from frame 1 for both close-up and distant terrain
    vec3 finalColor = mix(airResult, waterResult, waterFactor);

    return vec4(finalColor, u_NativeFogColor.a);
}

// Override u_FogColor globally for all Sodium shader files including this header
#define u_FogColor get_custom_fog_color()
// END CUSTOM CODE
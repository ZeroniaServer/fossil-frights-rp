#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 diffuseColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    if (!check_alpha(alpha, 250.0)) {
        color *= vertexColor;
    } else {
        color *= diffuseColor;
        color.a = 1.0;
    }
    color *= ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    if (!check_alpha(alpha, 250.0)) {
        color *= lightMapColor;
    }
    
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
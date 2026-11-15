#version 330
#extension GL_ARB_separate_shader_objects : require

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    mat4 TextureMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
};

uniform sampler2D Sampler0;

layout(location = 0) in vec2 texCoord0;
layout(location = 1) in vec4 vertexColor;

// CUSTOM CODE - ShaderSelector
#include <shader_selector:marker_settings.glsl>
layout(location = 2) flat in int isPerspective;
// END CUSTOM CODE

layout(location = 0) out vec4 fragColor;

void main() {
    // CUSTOM CODE - ShaderSelector
    // Detects 3D first-person overlays (e.g. underwater) and discards them at candidate marker pixels
    if (isPerspective == 1) {
        ivec2 iCoord = ivec2(gl_FragCoord.xy);
        if (false
            #define ADD_MARKER(i, green, alpha, op, r) || MARKER_POS(i) == iCoord
            LIST_MARKERS
        ) discard;
    }
    // END CUSTOM CODE

    vec4 color = texture(Sampler0, texCoord0) * vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    // CUSTOM CODE
    else if (color.a == 1/255. && color.rgb == vec3(1.0)) {
        discard;
    }
    // END CUSTOM CODE
    fragColor = color * ColorModulator;
}
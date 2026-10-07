#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;

// CUSTOM CODE
layout(location = 2) out mat4 ProjInv;

#define BOTTOM -32.0
#define SCALE 0.01
#define SKYHEIGHT 16.0
#define SKYRADIUS 512.0
#define FUDGE 0.004

void main() {
    vec3 scaledPos = Position;

    // The sky is transformed so that it always covers the entire camera view
    // Sky disk is by default 16.0 units above with radius of 512.0 around the camera at all times
    if (abs(scaledPos.y - SKYHEIGHT) < FUDGE) {
        // Make sky into a cone by bringing down edges of the disk
        if (length(scaledPos.xz) > 1.0) {
            scaledPos.y = BOTTOM;
        }

        // Make it big so it does not interfere with void plane
        scaledPos.xyz *= SCALE;

        // Rotate to Z axis
        scaledPos = scaledPos.xzy;
        scaledPos.z *= -1;

        // Ignore model view so the cone follows the camera angle
        gl_Position = ProjMat * vec4(scaledPos, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(scaledPos, 1.0);
    }

    ProjInv = inverse(ProjMat * ModelViewMat);
    sphericalVertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    cylindricalVertexDistance = sphericalVertexDistance;
}
// END CUSTOM CODE
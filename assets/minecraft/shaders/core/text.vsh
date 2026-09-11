#version 330

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:sample_lightmap.glsl>
#endif

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
in ivec2 UV2;
#endif

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
uniform sampler2D Sampler2;
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#endif

out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = Color * sample_lightmap(Sampler2, UV2);
#else
    vertexColor = Color;
#endif
    texCoord0 = UV0;

// custom text colors
#if defined(IS_GUI)
    // speedrun timer
    if (Color == vec4(172/255., 168/255., 0, Color.a)) {
        // nudge it some
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 38.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);

        // move to top right corner
        gl_Position.x -= gl_Position.w;

        // recolor to white
        vertexColor.rgb = vec3(1.0);
    }
    
    // speedrun timer shadow 
    else if (Color == vec4(43/255., 42/255., 0, Color.a)) {
        // nudge it some
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 38.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);

        // move to top right corner
        gl_Position.x -= gl_Position.w;

        // recolor to dark gray
        vertexColor.rgb = vec3(0.25);
    }

    // speedrun delta
    else if (Color == vec4(172/255., 168/255., 16/255., Color.a) || Color == vec4(0, 172/255., 168/255., Color.a)) {
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 48.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);
        gl_Position.x -= gl_Position.w;
        vertexColor.rgb = vec3(85/255., 1.0, 85/255.);
    }

    else if (Color == vec4(43/255., 42/255., 4/255., Color.a) || Color == vec4(0, 43/255., 42/255., Color.a)) {
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 48.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);
        gl_Position.x -= gl_Position.w;
        vertexColor.rgb = vec3(21/255., 63/255., 21/255.);
    }

    else if (Color == vec4(172/255., 168/255., 32/255., Color.a) || Color == vec4(172/255., 0, 168/255., Color.a)) {
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 48.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);
        gl_Position.x -= gl_Position.w;
        vertexColor.rgb = vec3(1.0, 85/255., 85/255.);
    }

    else if (Color == vec4(43/255., 42/255., 8/255., Color.a) || Color == vec4(43/255., 0, 42/255., Color.a)) {
        vec3 newPos = vec3(Position.x + 27.0, Position.y - 48.0, Position.z);
        gl_Position = ProjMat * ModelViewMat * vec4(newPos, 1.0);
        gl_Position.x -= gl_Position.w;
        vertexColor.rgb = vec3(63/255., 21/255., 21/255.);
    }
#endif
}

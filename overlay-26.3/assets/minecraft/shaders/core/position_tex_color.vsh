#version 330
#extension GL_ARB_separate_shader_objects : require

// Can't moj_import in things used during startup, when resource packs don't exist.
// This is a copy of dynamicimports.glsl and projection.glsl
layout(std140) uniform DynamicTransforms {
    mat4 ModelViewMat;
    mat4 TextureMat;
    vec4 ColorModulator;
    vec3 ModelOffset;
};
layout(std140) uniform Projection {
    mat4 ProjMat;
};

// CUSTOM CODE
uniform sampler2D Sampler0;
// END CUSTOM CODE

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;
layout(location = 2) in vec4 Color;

layout(location = 0) out vec2 texCoord0;
layout(location = 1) out vec4 vertexColor;

// CUSTOM CODE
/*
 * Vertex Color utility function provided by Ts
 * Retrieves the color of a vertex by adjusting the coordinates depending on the vertex id
 * "-offset" for gui elements "+offset" in other places, armor also has vertexIndex switched, probably more things
*/
vec4 getVertexColor(sampler2D Sampler, int vertexIndex, vec2 coords) {
	ivec2 texSize = textureSize(Sampler, 0); // get texture size
	vec2 offset = vec2(0.0); // init offset
	float pixelX = (1.0/texSize.x) / 2.0; // includes the width of the texture
	float pixelY = (1.0/texSize.y) / 2.0; // includes the height of the texture
	vertexIndex = vertexIndex % 4; // every plane has 4 vertices
	switch (vertexIndex) {
		case 1: offset = vec2(-pixelX, pixelY); break;
		case 2: offset = vec2(pixelX, pixelY); break;
		case 3: offset = vec2(pixelX, -pixelY); break;
		case 0: offset = vec2(-pixelX, -pixelY); break;
		default: offset = vec2(0.0); break;
	}
	return texture(Sampler, coords - offset); // retrieve vertex's pixel
}
// END CUSTOM CODE

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    texCoord0 = UV0;
    vertexColor = Color;

	// CUSTOM CODE
	// get the color of the vertex
	vec4 color = getVertexColor(Sampler0, gl_VertexIndex, texCoord0);
	// the vertex renders air icons, offset it.
	if (color.a == 1/255. && color.rgb == vec3(1.0)) {
		gl_Position = ProjMat * ModelViewMat * vec4(Position + vec3(0.0, 10.0, 0.0), 1.0);
	}
	// END CUSTOM CODE
}
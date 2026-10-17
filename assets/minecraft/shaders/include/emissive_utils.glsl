#ifndef ZERONIA_EMISSIVE_UTILS_GLSL
#define ZERONIA_EMISSIVE_UTILS_GLSL

// Checking for the exact alpha value breaks things
bool check_alpha(float textureAlpha, float targetAlpha) {
	float targetLess = targetAlpha - 0.01;
	float targetMore = targetAlpha + 0.01;
	return (textureAlpha > targetLess && textureAlpha < targetMore);
}

#endif
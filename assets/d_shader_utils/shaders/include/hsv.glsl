#ifndef d_shader_utils_hsv
#define d_shader_utils_hsv

// Following the calculation described by https://www.rapidtables.com/convert/color/rgb-to-hsv.html
// HSV on [0, 1]³
vec3 rgbToHsv(vec3 col) {
    float cMax = max(col.r, max(col.g, col.b));
    float cMin = min(col.r, min(col.g, col.b));
    float delta = cMax - cMin;
    if (delta == 0.0) return vec3(0.0, 0.0, cMax);
    float H = (
        cMax == col.r ? mod((col.g - col.b)/delta, 6.)
      : cMax == col.g ? (col.b - col.r)/delta + 2.
      : (col.r - col.g) / delta + 4.
    )/6.;
    float S = delta / cMax;
    return vec3(H, S, cMax);
}

#endif

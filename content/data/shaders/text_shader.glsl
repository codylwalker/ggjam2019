vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texcolor = Texel (texture, texture_coords);

    float b = 1.0;
    float alpha = smoothstep (0.0, 0.5, texcolor.a);
    return color * vec4 (b, b, b, alpha);
}

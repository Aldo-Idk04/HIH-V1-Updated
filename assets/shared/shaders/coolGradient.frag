#pragma header
const vec4 transparent = vec4(0, 0, 0, 0);

uniform vec3 gradientFrom;
uniform vec3 gradientTo;
uniform vec3 colorToAvoid;
uniform bool isHorizontal;

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);

    if (color != transparent && color.rgb != colorToAvoid && gradientTo != gradientFrom)
        color.rgb = mix(gradientFrom, gradientTo, vec3(isHorizontal ? uv.x : uv.y) * color.a);

    gl_FragColor = color;
}
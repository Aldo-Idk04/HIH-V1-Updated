// Made by TheLeerName for Flain <3
// looks like this https://api.haxeflixel.com/flixel/addons/effects/chainable/FlxGlitchEffect.html
// you can change some things below in defines

#pragma header

uniform float iTime; // u need update it tho

// its like multiplier of all width/height of sprite
#define GLITCH_STRENGTH 0.01

// frames per second
#define GLITCH_FPS 5

// in pixels
#define GLITCH_STEP 15

#define DO_HORIZONTAL
//#define DO_VERTICAL

#define REPEAT_WRAP
#define FLIP_IF_OUTSIDE_BOUNDS

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float doGlitchEffect(vec2 fragCoord, bool vertical) {
    float coord = (vertical ? fragCoord.x : fragCoord.y);

    float stepp = float(GLITCH_STEP);

    float floorStep = floor(coord / stepp);

    float fps = floor(iTime * float(GLITCH_FPS));

    bool direction = floorStep * stepp == coord;

    float value = rand(vec2(fps, floorStep)) * float(GLITCH_STRENGTH);

    return value * (direction ? 1. : -1.);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
	vec2 fragCoord = uv * openfl_TextureSize;

    #ifdef DO_HORIZONTAL
    uv.x += doGlitchEffect(fragCoord, false);
    #endif

    #ifdef DO_VERTICAL
    uv.y += doGlitchEffect(fragCoord, true);
    #endif

    #ifdef FLIP_IF_OUTSIDE_BOUNDS
    vec2 modded = mod(uv, vec2(2.));
    if (modded.x > 1.) uv.x = 1.0 - uv.x;
    if (modded.y > 1.) uv.y = 1.0 - uv.y;
    #endif

    #ifdef REPEAT_WRAP
    uv = mod(uv, vec2(1.));
    #endif

    gl_FragColor = flixel_texture2D(bitmap, uv);
}
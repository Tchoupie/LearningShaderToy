float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

vec3 sdfShape(vec2 uv, float size, vec2 offset)
{
    float x = uv.x - offset.x;
    float y = uv.y- offset.y;
    
    //r*=iTime/10.;
    //x*= 0.5*cos(iTime);
    //y*= 0.5*sin(iTime);
    
    x*= 1.-noise(vec2(x,y)+sin(iTime));
    y*= 1.-noise(vec2(x,y)+cos(iTime));
    
    //float d = length(vec2(x,y)) - r; //length(vec2(x,y) = sqrt(pow(x,2.) + pow(y,2.))
    float d = sqrt(pow(x,2.) + pow(y,2.)) - size; //Circle
    //float d = max(abs(x), abs(y)) - size; //Square
    
    //return d > 0. ? vec3(1.) : vec3(0.,0.,1.);
    return d > 0. ? vec3(0.) : 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0,2,4));

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv -= 0.5; //uv is located <-0.5, 0.5>
    uv.x *= iResolution.x/iResolution.y; // fix aspect ratio

    // Time varying pixel color
    //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4);
    vec3 col = vec3(0.);
    
    vec2 offset = vec2(sin(iTime*2.)*0.2, cos(iTime*2.)*0.2); // move the circle clockwise
    
    col = sdfShape(uv,.2,offset);
    // Output to screen
    fragColor = vec4(col,1.0);
}
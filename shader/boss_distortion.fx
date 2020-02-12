
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 SCREENSIZE;

uniform float centerX;
uniform float centerY;
uniform float size;
uniform float arg;
uniform vec4 color;
uniform float colorsize;
uniform float timer;

uniform sampler2D u_texture;

vec2 Distortion(vec2 xy, vec2 delta, float deltaLen)
{
    float k = deltaLen / size;
    float p = (k - 1.0) * (k - 1.0);
    vec2 delta1 = vec2(arg * 0.8 * sin((xy.x * 0.5 + xy.y) / 18.0 + timer / 5.0), 0.0);
    float a = mix(arg * 1.2, arg * 0.8, sin(timer / 10.0) * 0.5 + 1.0);
	float d2 = deltaLen * (1.0 - mix(pow(k, (1.0 + a)), k, k));
    vec2 delta2 = vec2(d2, d2);
    return delta1 * p + delta2 * p * 0.8;
}

void main()
{
    vec2 uv = v_texCoord;
    vec2 screen_size = vec2(SCREENSIZE.z - SCREENSIZE.x, SCREENSIZE.w - SCREENSIZE.y);
    vec2 center = vec2(centerX, screen_size.y - centerY);
    vec2 xy = uv * screen_size;
    vec2 delta = xy - center;
    float deltaLen = length(delta);
    delta = normalize(delta);

    if (deltaLen <= size) {
        vec2 distDelta = Distortion(xy, delta, deltaLen);
        uv += distDelta / screen_size;
    }

	gl_FragColor = v_fragmentColor * texture2D(u_texture, uv);
    
    if (deltaLen <= colorsize) {
        float k = deltaLen / colorsize;
        vec4 addColor = mix(color, vec4(0.0), k * k);
        gl_FragColor += addColor * addColor.a;
    }
//    gl_FragColor.a = 1;
}

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

varying float v_fogFactor;
uniform vec4 u_fogColor;

uniform sampler2D u_texture;

void main()
{
    gl_FragColor = v_fragmentColor + texture2D(u_texture, v_texCoord);
	gl_FragColor.w = gl_FragColor.w - v_fragmentColor.w;
	gl_FragColor.rgb = mix(u_fogColor.rgb, gl_FragColor.rgb, v_fogFactor);
}

#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
    vec4 tex = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor.rgb = v_fragmentColor.rgb + tex.rgb;
    gl_FragColor.a = tex.a * v_fragmentColor.a;
}

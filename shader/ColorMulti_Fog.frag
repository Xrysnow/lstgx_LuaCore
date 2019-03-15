#ifdef GL_ES
precision lowp float;
#endif

//precision highp float;

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

varying float v_fogFactor;
uniform vec4 u_fogColor;

void main()
{
    gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
	gl_FragColor.rgb = mix(u_fogColor.rgb, gl_FragColor.rgb, v_fogFactor);
	
//	gl_FragColor.r=v_fogFactor;
//	gl_FragColor.g=v_fogFactor;
//	gl_FragColor.b=v_fogFactor;
//	gl_FragColor.a=u_fogColor.a*0.001+0.999;
}

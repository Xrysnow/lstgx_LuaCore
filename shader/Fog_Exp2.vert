attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform mat4 u_MVPMatrix;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying lowp float v_fogFactor;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying float v_fogFactor;
#endif

uniform float u_fogDensity;

void main()
{
    gl_Position = u_MVPMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
	
	float fogFragCoord = abs(gl_Position.z);//get fog distance
	v_fogFactor = exp(-pow(u_fogDensity * fogFragCoord, 2.0));//exp2 fog
	v_fogFactor = clamp(v_fogFactor, 0.0, 1.0);//clamp 0 to 1
}

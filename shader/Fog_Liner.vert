attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

uniform mat4 u_MVPMatrix;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
#endif

varying float v_fogFactor;
uniform float u_fogStart;
uniform float u_fogEnd;

void main()
{
    gl_Position = u_MVPMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
	
	float fogFragCoord = abs(gl_Position.w);//get fog distance
	v_fogFactor = (u_fogEnd - fogFragCoord) / (u_fogEnd - u_fogStart);//linear fog
	v_fogFactor = clamp(v_fogFactor, 0.0, 1.0);//clamp 0 to 1
}

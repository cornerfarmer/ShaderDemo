[Vertex_Shader]
#version 440
in vec4 gxl3d_Position;

uniform mat4 gxl3d_ModelViewProjectionMatrix;

void main()
{
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
}

[Pixel_Shader]
#version 440

out vec4 Out_Color;
void main()
{
	float f = 50.0;

	float n = 0.1;

	float z = (2 * n) / (f + n - gl_FragCoord.z * (f - n));
	Out_Color = vec4(z);
}


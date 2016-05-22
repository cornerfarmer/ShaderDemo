[Vertex_Shader]
#version 440
// Inputs
in vec4 gxl3d_Position;
// Const inputs
uniform mat4 gxl3d_ModelViewProjectionMatrix;
// Outputs
out vec4 position;
void main()
{
    position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	gl_Position  = position;
}

[Pixel_Shader]
#version 440
// Inputs
in vec4 position;
// Outputs
out vec4 Out_Color;
void main()
{
	// Just render the depth value
	Out_Color = vec4(position.z / 50.0);
}


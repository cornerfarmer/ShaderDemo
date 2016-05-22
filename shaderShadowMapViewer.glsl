[Vertex_Shader]
#version 440
// Inputs
in vec4 gxl3d_Position;
in vec4 gxl3d_TexCoord0;
// Const inputs
uniform mat4 gxl3d_ModelViewProjectionMatrix;
// Outputs
out vec4 TexCoord;
void main()
{
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	TexCoord = gxl3d_TexCoord0;
}

[Pixel_Shader]
#version 440
// Inputs
in vec4 TexCoord;
// Const inputs
uniform sampler2D tex0;
// Outputs
out vec4 Out_Color;
void main()
{
	Out_Color = texture(tex0, TexCoord.xy);
}
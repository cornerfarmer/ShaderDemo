[Vertex_Shader]
#version 440


in vec4 gxl3d_Position;
in vec4 gxl3d_TexCoord0;
out vec4 Vertex_UV;
uniform mat4 gxl3d_ModelViewProjectionMatrix;

void main()
{
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	Vertex_UV = gxl3d_TexCoord0;
}

[Pixel_Shader]
#version 440
in vec4 Vertex_UV;

out vec4 Out_Color;
uniform sampler2D tex0;
void main()
{
	Out_Color = texture(tex0, Vertex_UV.xy);
}


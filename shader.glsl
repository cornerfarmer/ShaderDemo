[Vertex_Shader]
#version 440


in vec4 gxl3d_Position;
in vec4 gxl3d_Color;
in vec4 gxl3d_Normal;
in vec4 gxl3d_TexCoord0;

uniform mat4 gxl3d_ModelViewProjectionMatrix;
uniform mat4 gxl3d_ModelViewMatrix;
uniform mat4 gxl3d_ModelMatrix;
out vec4 normal;
out vec4 TexCoord;
void main()
{
    normal = gxl3d_ModelMatrix * gxl3d_Normal;
   
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	TexCoord = gxl3d_TexCoord0;
}



[Pixel_Shader]
#version 440

uniform vec4 camera;
uniform vec4 lightSource;
uniform sampler2D tex0;

in vec4 normal;
in vec4 TexCoord;
out vec4 Out_Color;
void main()
{
	vec4 n = normalize(normal);

	vec4 eye = normalize(-camera);
    vec4 normLightSource = -1 * normalize(lightSource);

    float intensity = max(dot(n, normLightSource), 0.15);
    vec4 H = normalize(eye + normLightSource);
	float specular = max(pow(dot(H, n), 100), 0);

	Out_Color = texture(tex0, TexCoord.xy) * intensity +specular;
}


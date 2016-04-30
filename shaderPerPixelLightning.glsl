[Vertex_Shader]
#version 440


in vec4 gxl3d_Position;
in vec4 gxl3d_Color;
in vec4 gxl3d_Normal;
uniform mat4 gxl3d_ModelViewProjectionMatrix;
uniform mat4 gxl3d_ModelViewMatrix;
out vec4 normal;
out vec4 Color;
void main()
{
    normal = gxl3d_Normal;
   
    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	Color = gxl3d_Color;
}



[Pixel_Shader]
#version 440

uniform vec4 camera;
uniform vec4 lightSource;

in vec4 normal;
in vec4 Color;
out vec4 Out_Color;
void main()
{
	vec4 n = normalize(normal);

	vec4 eye = normalize(-camera);
    vec4 normLightSource = normalize(lightSource);

    float intensity = max(dot(n, normLightSource), 0.0);
    vec4 H = normalize(eye + normLightSource);
	float specular = max(pow(dot(H, n), 30), 0);

	Out_Color = intensity * Color + specular;
}


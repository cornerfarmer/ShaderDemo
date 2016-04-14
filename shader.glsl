[Vertex_Shader]
#version 440


in vec4 gxl3d_Position;
in vec4 gxl3d_Color;
in vec4 gxl3d_Normal; 

uniform mat4 gxl3d_ModelViewProjectionMatrix; 
uniform mat4 gxl3d_ModelViewMatrix; 
uniform vec4 camera; 
uniform vec4 lightSource; 

out vec4 Color;

void main()
{
vec4 normLightSource = normalize(lightSource);
  float intensity = max(dot(gxl3d_Normal, normLightSource), 0.3);

  vec4 eye = normalize(-camera);
  vec4 H = normalize(eye + normLightSource);
  float specular = max(pow(dot(H, gxl3d_Normal), 15), 0);

  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
  Color = intensity * gxl3d_Color + specular;
}


[Pixel_Shader]
#version 440

in vec4 Color;
out vec4 Out_Color;

void main()
{
  Out_Color = Color;
}


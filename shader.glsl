[Vertex_Shader]
#version 440


in vec4 gxl3d_Position;
in vec4 gxl3d_Color;
in vec4 gxl3d_Normal;
in vec4 gxl3d_TexCoord0;

uniform mat4 gxl3d_ModelViewProjectionMatrix;
uniform mat4 gxl3d_ModelViewMatrix;
uniform mat4 gxl3d_ModelMatrix;
out vec4 vNormal;
out vec4 vOrgPosition;
out vec4 vTexCoord;
void main()
{
    vNormal = gxl3d_ModelMatrix * gxl3d_Normal;

    gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
	vTexCoord = gxl3d_TexCoord0;
	vOrgPosition = gxl3d_ModelMatrix * gxl3d_Position;
}

[Geometry_Shader]
#version 440
 
layout(triangles) in;
layout (triangle_strip, max_vertices=3) out;
 
in vec4 vNormal[3];
in vec4 vTexCoord[3];
in vec4 vOrgPosition[3];
 
out vec4 normal;
out vec3 tangent;
out vec4 TexCoord;
out vec3 bitangent;

 void main()
{
	
	vec4 edge1 = vOrgPosition[1] - vOrgPosition[0];
	vec4 edge2 = vOrgPosition[2] - vOrgPosition[0];
	vec4 deltaUV1 = vTexCoord[1] - vTexCoord[0];
	vec4 deltaUV2 = vTexCoord[2] - vTexCoord[0];  

	float f = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);

	vec3 ptangent;
	ptangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
	ptangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
	ptangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);

	vec3 pbitangent;
	pbitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
	pbitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
	pbitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
	
  for(int i = 0; i < 3; i++)
  {
     // copy attributes
    gl_Position = gl_in[i].gl_Position;
    normal = vNormal[i];
    TexCoord = vTexCoord[i];
	tangent = ptangent;
	bitangent = pbitangent;
 
    // done with the vertex
    EmitVertex();
  }
}

[Pixel_Shader]
#version 440

uniform vec4 camera;
uniform vec4 lightSource;
uniform sampler2D tex0;
uniform sampler2D tex1;

in vec4 normal;
in vec3 tangent;
in vec4 TexCoord;
in vec3 bitangent;
out vec4 Out_Color;
void main()
{
	
	vec3 bump = texture(tex1, TexCoord.xy).xyz * 2 - vec3(1);
	mat3 TBN = mat3(normalize(tangent), normalize(bitangent), normalize(normal.xyz));
	vec4 n = vec4(normalize(TBN * bump), 0);

	vec4 eye = normalize(-camera);
    vec4 normLightSource = -1 * normalize(lightSource);

    float intensity = max(dot(n, normLightSource), 0.15);
    vec4 H = normalize(eye + normLightSource);
	float specular = max(pow(dot(H, n), 100), 0) * 0.3;

	Out_Color = texture(tex0, TexCoord.xy) * intensity + specular;
}


[Vertex_Shader]
#version 440
// Inputs
in vec4 gxl3d_Position;
in vec4 gxl3d_Color;
in vec4 gxl3d_Normal;
in vec4 gxl3d_TexCoord0;
// Const inputs
uniform mat4 gxl3d_ModelViewProjectionMatrix;
uniform mat4 gxl3d_ModelViewMatrix;
uniform mat4 gxl3d_ModelMatrix;
uniform mat4 lightProjectionMatrix;
uniform mat4 lightViewMatrix;
// Outputs
out vec4 vNormal;
out vec4 vOrgPosition;
out vec4 vTexCoord;
out vec4 vPosInLightSpace;
void main()
{
	vNormal = gxl3d_ModelMatrix * gxl3d_Normal;
	vOrgPosition = gxl3d_ModelMatrix * gxl3d_Position;
	vTexCoord = gxl3d_TexCoord0;
	vPosInLightSpace = lightProjectionMatrix * lightViewMatrix * gxl3d_ModelMatrix * gxl3d_Position;
	gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;
}


[Geometry_Shader]
#version 440 
layout(triangles) in;
layout (triangle_strip, max_vertices=3) out;
// Inputs
in vec4 vNormal[3];
in vec4 vTexCoord[3];
in vec4 vOrgPosition[3];
in vec4 vPosInLightSpace[3];
// Outputs
out vec4 normal;
out vec3 tangent;
out vec4 TexCoord;
out vec3 bitangent;
out vec4 posInLightSpace;
void main()
{
	// Precalculations
	vec4 edge1 = vOrgPosition[1] - vOrgPosition[0];
	vec4 edge2 = vOrgPosition[2] - vOrgPosition[0];
	vec4 deltaUV1 = vTexCoord[1] - vTexCoord[0];
	vec4 deltaUV2 = vTexCoord[2] - vTexCoord[0];
	float f = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
	// Calc tangent
	vec3 ptangent;
	ptangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
	ptangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
	ptangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
	// Calc bitangent
	vec3 pbitangent;
	pbitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
	pbitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
	pbitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
	for(int i = 0; i < 3; i++)
	{
		// Copy attributes
		gl_Position = gl_in[i].gl_Position;
		normal = vNormal[i];
		TexCoord = vTexCoord[i];
		tangent = ptangent;
		bitangent = pbitangent;
		posInLightSpace = vPosInLightSpace[i];
		// Done with the vertex
		EmitVertex();
	}

}

[Pixel_Shader]
#version 440
// Inputs
in vec4 normal;
in vec3 tangent;
in vec4 TexCoord;
in vec3 bitangent;
in vec4 posInLightSpace;
// Const inputs
uniform vec4 camera;
uniform vec4 lightDir;
uniform vec4 lightPos;
uniform float lightPower;
uniform sampler2D tex0;
uniform sampler2D tex1;
uniform sampler2D normTex;
uniform sampler2D shadowMap;
uniform int graphicsMode;
// Outputs
out vec4 Out_Color;
void main()
{
	// Precomputations
	vec4 eye = normalize(-camera);
	vec4 normLightDir = normalize(lightDir);

	vec4 n;
	if (graphicsMode >= 4) {
		// Normalmapping
		vec3 bump = texture(tex1, TexCoord.xy).xyz * 2 - vec3(1);
		mat3 TBN = mat3(normalize(tangent), normalize(bitangent), normalize(normal.xyz));
		n = vec4(normalize(TBN * bump), 0);
	} else {
		n = normalize(normal);
	}

	// Diffuse ligtning
	float intensity = -1 * dot(n, normLightDir);

	// Speculat lightning
	vec4 H = reflect(normLightDir, n);
	float specular = max(pow(dot(H, eye), 20), 0) * 0.3;

	// Shadow mapping
	float storedDistance = texture(shadowMap, posInLightSpace.xy / posInLightSpace.w / 2.0 + 0.5).x;
	float realDistance = posInLightSpace.z / 50;
	float visibility = 1.0;
	float bias = 0.005;
	if (storedDistance < realDistance - bias)
		visibility = 0.4;

	// Combine results
	if (graphicsMode == 1)
		Out_Color = vec4(0.5);
	if (graphicsMode >= 2)
		Out_Color = texture(tex0, TexCoord.xy);
	if (graphicsMode >= 3)
		Out_Color *= intensity;
	if (graphicsMode >= 4)
		Out_Color *= lightPower;
	if (graphicsMode >= 6)
		Out_Color += specular;
	if (graphicsMode >= 7)
		Out_Color *= visibility;
	if (graphicsMode >= 5)
		Out_Color = max(Out_Color, texture(tex0, TexCoord.xy) * 0.15);
}



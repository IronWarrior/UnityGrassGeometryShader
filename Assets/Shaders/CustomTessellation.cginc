// Tessellation programs based on this article by Catlike Coding:
// https://catlikecoding.com/unity/tutorials/advanced-rendering/tessellation/

struct vertexInput
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
};

struct vertexOutput
{
	float4 vertex : SV_POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
};

struct TessellationFactors 
{
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

vertexInput vert(vertexInput v)
{
	return v;
}

vertexOutput tessVert(vertexInput v)
{
	vertexOutput o;
	// Note that the vertex is NOT transformed to clip
	// space here; this is done in the grass geometry shader.
	o.vertex = v.vertex;
	o.normal = v.normal;
	o.tangent = v.tangent;
	return o;
}

float _TessellationUniform;

TessellationFactors patchConstantFunction (InputPatch<vertexInput, 3> patch)
{
	TessellationFactors f;
	f.edge[0] = _TessellationUniform;
	f.edge[1] = _TessellationUniform;
	f.edge[2] = _TessellationUniform;
	f.inside = _TessellationUniform;
	return f;
}

[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]
[UNITY_outputtopology("triangle_cw")]
[UNITY_partitioning("integer")]
[UNITY_patchconstantfunc("patchConstantFunction")]
vertexInput hull (InputPatch<vertexInput, 3> patch, uint id : SV_OutputControlPointID)
{
	return patch[id];
}

[UNITY_domain("tri")]
vertexOutput domain(TessellationFactors factors, OutputPatch<vertexInput, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
{
	vertexInput v;

	#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = \
		patch[0].fieldName * barycentricCoordinates.x + \
		patch[1].fieldName * barycentricCoordinates.y + \
		patch[2].fieldName * barycentricCoordinates.z;

	MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
	MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
	MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)

	return tessVert(v);
}
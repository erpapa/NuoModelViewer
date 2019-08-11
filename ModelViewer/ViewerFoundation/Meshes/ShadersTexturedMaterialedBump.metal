
#include "ShadersCommon.h"

using namespace metal;

struct Vertex
{
    float4 position;
    float4 normal;
    float4 tangent;
    float4 bitangent;
    float2 texCoord;
    
    float3 diffuseColor;
    float3 ambientColor;
    float3 specularColor;
    float2 specularPowerDisolve;
};

struct ProjectedVertex
{
    float4 position     [[position]];
    float4 positionNDC;
    float3 eye;
    float3 normal;
    float3 tangent;
    float3 bitangent;
    float2 texCoord;
    
    float3 diffuseColor;
    float3 ambientColor;
    float3 specularColor;
    float specularPower;
    float dissolve [[flat]];
    
    float4 shadowPosition0;
    float4 shadowPosition1;
};



vertex ProjectedVertex vertex_tex_materialed_tangent(device Vertex *vertices [[buffer(0)]],
                                                     constant NuoUniforms &uniforms [[buffer(1)]],
                                                     constant NuoLightVertexUniforms &lightCast [[buffer(2)]],
                                                     constant NuoMeshUniforms &meshUniforms [[buffer(3)]],
                                                     uint vid [[vertex_id]])
{
    ProjectedVertex outVert;
    
    float4 meshPosition = meshUniforms.transform * vertices[vid].position;
    float4 eyePosition = uniforms.viewMatrixInverse * float4(0.0, 0.0, 0.0, 1.0);
    float3x3 normalMatrix = meshUniforms.normalTransform;
    
    outVert.position = uniforms.viewProjectionMatrix * meshPosition;
    outVert.positionNDC = uniforms.viewProjectionMatrix * meshPosition;
    outVert.eye = eyePosition.xyz - meshPosition.xyz;
    outVert.normal = normalMatrix * vertices[vid].normal.xyz;
    outVert.tangent = normalMatrix * (vertices[vid].tangent.xyz);
    outVert.bitangent = normalMatrix * (vertices[vid].bitangent.xyz);
    outVert.texCoord = vertices[vid].texCoord;
    
    outVert.ambientColor = vertices[vid].ambientColor;
    outVert.diffuseColor = vertices[vid].diffuseColor;
    outVert.specularColor = vertices[vid].specularColor;
    outVert.specularPower = vertices[vid].specularPowerDisolve.x;
    outVert.dissolve = vertices[vid].specularPowerDisolve.y;
    
    outVert.shadowPosition0 = lightCast.lightCastMatrix[0] * meshPosition;
    outVert.shadowPosition1 = lightCast.lightCastMatrix[1] * meshPosition;
    
    return outVert;
}



static VertexFragmentCharacters vertex_characters(ProjectedVertex vert);
static float3 bumpped_normal(float3 normal, float3 tangent, float3 bitangent, float3 bumpNormal);



/**
 *  shaders that generates screen-space position only, used for stencile-based color,
 *  or depth-only rendering (e.g. shadow-map)
 */

vertex PositionSimple vertex_simple_tex_materialed_bump(device Vertex *vertices [[buffer(0)]],
                                                        constant NuoUniforms &uniforms [[buffer(1)]],
                                                        constant NuoMeshUniforms &meshUniforms [[buffer(2)]],
                                                        uint vid [[vertex_id]])
{
    return vertex_simple<Vertex>(vertices, uniforms, meshUniforms, vid);
}




fragment float4 fragment_tex_materialed_bump(ProjectedVertex vert [[stage_in]],
                                             constant NuoLightUniforms &lighting [[buffer(0)]],
                                             texture_array<2>::t shadowMaps    [[texture(0)]],
                                             texture_array<2>::t shadowMapsExt [[texture(2)]],
                                             texture2d<float> depth            [[texture(4), function_constant(kDepthPrerenderred)]],
                                             texture2d<float> diffuseTexture   [[texture(5)]],
                                             texture2d<float> opacityTexture   [[texture(6),
                                                                               function_constant(kAlphaChannelInSeparatedTexture)]],
                                             texture2d<float> bumpTexture [[texture(7)]],
                                             sampler depthSamplr [[sampler(0)]],
                                             sampler samplr [[sampler(1)]])
{
    if (kMeshMode == kMeshMode_Selection)
        return diffuse_lighted_selection(vert.positionNDC, vert.normal, depth, depthSamplr);
    
    VertexFragmentCharacters outVert = vertex_characters(vert);
    
    float4 diffuseTexel = diffuseTexture.sample(samplr, vert.texCoord);
    float4 opacityTexel = 1.0;
    if (kAlphaChannelInSeparatedTexture)
        opacityTexel = opacityTexture.sample(samplr, vert.texCoord);
    
    float4 diffuseColor = diffuse_common(diffuseTexel, opacityTexel.a);
    outVert.diffuseColor = diffuseColor.rgb * outVert.diffuseColor;
    outVert.opacity = diffuseColor.a * outVert.opacity;
    
    float4 bumpNormal = bumpTexture.sample(samplr, vert.texCoord);
    outVert.normal = bumpped_normal(vert.normal, vert.tangent, vert.bitangent, bumpNormal.xyz);
    
    return fragment_light_tex_materialed_common(outVert, lighting, shadowMaps, shadowMapsExt, depthSamplr);
}


VertexFragmentCharacters vertex_characters(ProjectedVertex vert)
{
    VertexFragmentCharacters outVert;
    
    outVert.projectedNDC = vert.positionNDC;
    
    outVert.eye = vert.eye;
    outVert.diffuseColor = vert.diffuseColor;
    outVert.specularColor = vert.specularColor;
    outVert.specularPower = vert.specularPower;
    outVert.opacity = vert.dissolve;
    
    outVert.shadowPosition[0] = vert.shadowPosition0;
    outVert.shadowPosition[1] = vert.shadowPosition1;
    
    return outVert;
}



float3 bumpped_normal(float3 normal, float3 tangent, float3 bitangent, float3 bumpNormal)
{
    bumpNormal = normalize((bumpNormal * 2. - float3(1.)));
    bumpNormal.y =  -bumpNormal.y;
    
    tangent = normalize(tangent);
    bitangent = normalize(bitangent);
    normal = normalize(normal);
    float3x3 m = { tangent, bitangent , normal };
    
    return normalize(m * bumpNormal);
}


#pragma mark -- Screen Space Shader --


vertex VertexScreenSpace vertex_screen_space_tex_materialed_bump(device Vertex *vertices [[buffer(0)]],
                                                                 constant NuoUniforms &uniforms [[buffer(1)]],
                                                                 constant NuoMeshUniforms &meshUniform [[buffer(3)]],
                                                                 uint vid [[vertex_id]])
{
    VertexScreenSpace result;
    
    float4 meshPosition = meshUniform.transform * vertices[vid].position;
    float3 meshNormal = meshUniform.normalTransform * vertices[vid].normal.xyz;
    
    result.projectedPosition = uniforms.viewProjectionMatrix * meshPosition;
    result.position =  uniforms.viewMatrix * meshPosition;
    result.normal = float4(meshNormal, 1.0);
    result.diffuseColorFactor = vertices[vid].diffuseColor;
    result.texCoord = vertices[vid].texCoord;
    result.opacity = vertices[vid].specularPowerDisolve.y;
    
    return result;
}




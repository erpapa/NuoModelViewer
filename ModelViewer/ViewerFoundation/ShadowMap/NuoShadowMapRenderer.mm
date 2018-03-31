//
//  NuoShadowMapRenderer.m
//  ModelViewer
//
//  Created by middleware on 1/16/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#import "NuoShadowMapRenderer.h"

#import "NuoLightSource.h"
#import "NuoShadowMapTarget.h"

#import "NuoMesh.h"
#import "NuoMeshBounds.h"

#include "NuoUniforms.h"
#include "NuoMathUtilities.h"



@interface NuoShadowMapRenderer()

@property (nonatomic, strong) NSArray<id<MTLBuffer>>* transUniformBuffers;

@end



@implementation NuoShadowMapRenderer
{
    matrix_float4x4 _lightCastMatrix;
}



- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue withName:(NSString *)name
{
    self = [super init];
    
    if (self)
    {
        self.renderTarget = [[NuoShadowMapTarget alloc] initWithCommandQueue:commandQueue
                                                             withPixelFormat:MTLPixelFormatBGRA8Unorm
                                                             withSampleCount:1];
        self.commandQueue = commandQueue;
        
        ((NuoShadowMapTarget*)self.renderTarget).name = name;
        
        [self makeResources];
    }
    
    return self;
}


- (void)makeResources
{
    id<MTLBuffer> transBuffers[kInFlightBufferCount];
    
    for (size_t i = 0; i < kInFlightBufferCount; ++i)
    {
        transBuffers[i] = [self.commandQueue.device newBufferWithLength:sizeof(NuoUniforms)
                                                                options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    _transUniformBuffers = [[NSArray alloc] initWithObjects:transBuffers count:kInFlightBufferCount];
}


- (void)updateUniformsForView:(unsigned int)inFlight
{
    static const float kCameraDistance = 1.0;
    
    vector_float4 center = {0, 0, 0, 1};
    float meshRadius = 0.0;
    
    vector_float4 lightAsEye = {0, 0, kCameraDistance, 1};
    vector_float3 up = {0, 1, 0};
    
    NuoLightSource* lightSource = _lightSource;
    const matrix_float4x4 lightAsEyeMatrix = matrix_rotate(lightSource.lightingRotationX,
                                                           lightSource.lightingRotationY);
    lightAsEye = matrix_multiply(lightAsEyeMatrix, lightAsEye);
    lightAsEye = lightAsEye + center;
    lightAsEye.w = 1.0;
    
    const matrix_float4x4 viewMatrix = matrix_lookAt(lightAsEye.xyz, center.xyz, up);
    
    CGSize drawableSize = self.renderTarget.drawableSize;
    float aspectRatio = drawableSize.width / drawableSize.height;
    
    NuoSphere sphere;
    NuoBounds bounds;
    if (_meshes && _meshes.count > 0)
    {
        sphere = *((NuoSphere*)[[_meshes[0] bounds] boundingSphere]);
        bounds = *((NuoBounds*)[[_meshes[0] bounds] boundingBox]);
        for (NSUInteger i = 1; i < _meshes.count; ++i)
        {
            sphere = sphere.Union(*((NuoSphere*)[_meshes[i] bounds].boundingSphere));
            bounds = bounds.Union(*((NuoBounds*)[_meshes[i] bounds].boundingBox));
        }
        
        center.xyz = sphere._center.xyz;
        meshRadius = sphere._radius;
    }
    bounds = bounds.Transform(viewMatrix);
    
    float viewPortHeight = meshRadius;
    float viewPortWidth = aspectRatio * viewPortHeight;
    float near = -bounds._span.z / 2.0 - bounds._center.z;
    float far =   bounds._span.z / 2.0 - bounds._center.z;
    
    const matrix_float4x4 projectionMatrix = matrix_orthor(-viewPortWidth, viewPortWidth,
                                                           viewPortHeight, -viewPortHeight,
                                                           near, far);
    
    NuoUniforms uniforms;
    uniforms.viewMatrix = viewMatrix;
    uniforms.viewProjectionMatrix = matrix_multiply(projectionMatrix, uniforms.viewMatrix);
    
    _lightCastMatrix = uniforms.viewProjectionMatrix;
    
    memcpy([self.transUniformBuffers[inFlight] contents], &uniforms, sizeof(uniforms));
}


- (void)drawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer withInFlightIndex:(unsigned int)inFlight
{
    [self updateUniformsForView:inFlight];
    
    id<MTLRenderCommandEncoder> renderPass = [self retainDefaultEncoder:commandBuffer];
    if (!renderPass)
        return;
    
    renderPass.label = @"Shadow Map";

    [renderPass setVertexBuffer:self.transUniformBuffers[inFlight] offset:0 atIndex:1];
    for (NuoMesh* mesh in _meshes)
    {
        if (mesh.enabled)
            [mesh drawShadow:renderPass indexBuffer:inFlight];
    }
    
    [self releaseDefaultEncoder];
}



- (matrix_float4x4)lightCastMatrix
{
    return _lightCastMatrix;
}


@end
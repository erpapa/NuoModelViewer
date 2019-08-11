//
//  NuoRayTracingRenderer.h
//  ModelViewer
//
//  Created by middleware on 6/11/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoRenderPipelinePass.h"
#import "NuoMesh.h"



@class NuoRayBuffer;
@class NuoComputePipeline;
@class NuoRayAccelerateStructure;



@interface NuoRayTracingRenderer : NuoRenderPipelinePass

@property (nonatomic, assign) CGFloat fieldOfView;

@property (nonatomic, weak) NuoMesh* mesh;
@property (nonatomic, weak) NuoRayAccelerateStructure* rayStructure;

@property (nonatomic, readonly) id<MTLBuffer> intersectionBuffer;
@property (nonatomic, readonly) NSArray<id<MTLTexture>>* targetTextures;


/**
 *  pixelFormat - one channel per kind of objects (e.g. opaque, translucent ...)
 *  targetCount - one target which is accumulated by monte carlo method
 */
- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue
                     withPixelFormat:(MTLPixelFormat)pixelFormat
                     withTargetCount:(uint)targetCount;

- (void)resetResources;

/**
 *  overridden by subclass, with compute-shader running for ray tracing
 */
- (void)runRayTraceShade:(NuoCommandBuffer*)commandBuffer;


/**
 *  functions called from within "- (void)runRayTraceShade:..."
 */
- (BOOL)primaryRayIntersect:(NuoCommandBuffer*)commandBuffer;
- (BOOL)rayIntersect:(NuoCommandBuffer*)commandBuffer
            withRays:(NuoRayBuffer*)rayBuffer withIntersection:(id<MTLBuffer>)intersection;


- (void)primaryRayEmit:(NuoCommandBuffer*)commandBuffer;
- (void)updatePrimaryRayMask:(uint32)mask withCommandBuffer:(NuoCommandBuffer*)commandBuffer;

/**
 *  protocol with "pipeline" shader:
 *  parameter buffers:
 *      0. ray volume uniform
 *      1. model index buffer
 *      2. model materials (per vertex)
 *      3. exitant rays (if null, parmiary/camera ray for the first sub-path)
 *      4. intersections
 *      5 .. m. "paramterBuffers" (e.g. shadow rays and/or random incidential rays)
 *      m+1. surface mask (when exiteant ray is nil only)
 *      m+1 .. (m+1+targetCount). target textures
 *      (m+1+targetCount)-... model material textures
 */
- (void)runRayTraceCompute:(NuoComputePipeline*)pipeline
         withCommandBuffer:(NuoCommandBuffer*)commandBuffer
             withParameter:(NSArray<id<MTLBuffer>>*)paramterBuffers
            withExitantRay:(id<MTLBuffer>)exitantRay
          withIntersection:(id<MTLBuffer>)intersection;


- (void)rayStructUpdated;


@end



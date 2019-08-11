//
//  ModelRayTracingBlendRenderer.h
//  ModelViewer
//
//  Created by middleware on 8/27/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoRenderPipelinePass.h"
#import "NuoIlluminationMesh.h"



@class ModelDirectLighting;



@interface ModelRayTracingBlendRenderer : NuoRenderPass


@property (nonatomic, weak) id<MTLTexture> immediateResult;
@property (nonatomic, weak) id<MTLTexture> illumination;
@property (nonatomic, weak) id<MTLTexture> illuminationOnVirtual;
@property (nonatomic, weak) id<MTLTexture> translucentMap;

@property (nonatomic, strong) NSArray<ModelDirectLighting*>* directLighting;


- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue
                     withPixelFormat:(MTLPixelFormat)pixelFormat
                     withSampleCount:(uint)sampleCount;

- (void)setAmbient:(const NuoVectorFloat3&)ambient;


@end



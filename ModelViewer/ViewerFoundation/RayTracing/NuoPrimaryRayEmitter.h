//
//  RayEmittor.h
//  ModelViewer
//
//  Created by middleware on 6/11/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#import "NuoRenderPassTarget.h"

#include "NuoMathVector.h"


@class NuoRayBuffer;
@class NuoCommandBuffer;
@protocol NuoRenderInFlight;


@interface NuoPrimaryRayEmitter : NSObject


/**
 *  ray emittor holds only information regarding the volumn's shape. it holds no
 *  information regarding how large the film is. the file is determined by the ray
 *  buffer taken by the emitting function
 *
 *  that implies the same emittor could be adapt to different sizes of films
 */
@property (nonatomic, assign) CGFloat fieldOfView;
@property (nonatomic, assign) NuoMatrixFloat44 viewTrans;

- (instancetype)initWithCommandQueue:(id<MTLCommandQueue>)commandQueue;

- (void)emitToBuffer:(NuoRayBuffer*)rayBuffer withCommandBuffer:(NuoCommandBuffer*)commandBuffer;
- (id<MTLBuffer>)uniformBuffer:(id<NuoRenderInFlight>)inFlight;



@end


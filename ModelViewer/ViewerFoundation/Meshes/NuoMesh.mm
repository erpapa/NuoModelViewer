
#import "NuoMesh.h"

#include "tiny_obj_loader.h"

#include "NuoModelBase.h"
#include "NuoTypes.h"

#import <Cocoa/Cocoa.h>
#import "NuoMeshTextured.h"



@implementation NuoMeshBox


- (NuoMeshBox*)unionWith:(NuoMeshBox*)other
{
    NuoMeshBox* newBox = [NuoMeshBox new];
    
    float xMin = std::min(_centerX - _spanX / 2.0, other.centerX - other.spanX / 2.0);
    float xMax = std::max(_centerX + _spanX / 2.0, other.centerX + other.spanX / 2.0);
    float yMin = std::min(_centerY - _spanY / 2.0, other.centerY - other.spanY / 2.0);
    float yMax = std::max(_centerY + _spanY / 2.0, other.centerY + other.spanY / 2.0);
    float zMin = std::min(_centerZ - _spanZ / 2.0, other.centerZ - other.spanZ / 2.0);
    float zMax = std::max(_centerZ + _spanZ / 2.0, other.centerZ + other.spanZ / 2.0);
    
    newBox.centerX = (xMax + xMin) / 2.0f;
    newBox.centerY = (yMax + yMin) / 2.0f;
    newBox.centerZ = (zMax + zMin) / 2.0f;
    
    newBox.spanX = xMax - xMin;
    newBox.spanY = yMax - yMin;
    newBox.spanZ = zMax - zMin;
    
    return newBox;
}


@end





@implementation NuoMesh




@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;
@synthesize boundingBox = _boundingBox;





- (instancetype)initWithDevice:(id<MTLDevice>)device
            withVerticesBuffer:(void*)buffer withLength:(size_t)length
                   withIndices:(void*)indices withLength:(size_t)indicesLength
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:buffer
                                            length:length
                                           options:MTLResourceOptionCPUCacheModeDefault];
        
        _indexBuffer = [device newBufferWithBytes:indices
                                           length:indicesLength
                                          options:MTLResourceOptionCPUCacheModeDefault];
        _device = device;
        
        [self makePipelineState];
    }
    
    return self;
}



- (void)makePipelineState
{
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_project"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_light"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    NSError *error = nil;
    _renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                       error:&error];
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    _depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}



- (void)drawMesh:(id<MTLRenderCommandEncoder>) renderPass
{
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];

    [renderPass setRenderPipelineState:_renderPipelineState];
    [renderPass setDepthStencilState:_depthStencilState];
    
    [renderPass setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[_indexBuffer length] / sizeof(uint32_t)
                            indexType:MTLIndexTypeUInt32
                          indexBuffer:_indexBuffer
                    indexBufferOffset:0];
}


- (BOOL)hasTransparency
{
    return NO;
}


@end





NuoMesh* CreateMesh(NSString* type,
                    id<MTLDevice> device,
                    const std::shared_ptr<NuoModelBase> model)
{
    std::string typeStr(type.UTF8String);
    
    if (typeStr == kNuoModelType_Simple)
    {
        return [[NuoMesh alloc] initWithDevice:device
                            withVerticesBuffer:model->Ptr()
                                    withLength:model->Length()
                                   withIndices:model->IndicesPtr()
                                    withLength:model->IndicesLength()];
    }
    else if (typeStr == kNuoModelType_Textured || typeStr == kNuoModelType_Textured_Transparency)
    {
        NSString* modelTexturePath = [NSString stringWithUTF8String:model->GetTexturePath().c_str()];
        BOOL checkTransparency = (typeStr == kNuoModelType_Textured_Transparency);
        
        return [[NuoMeshTextured alloc] initWithDevice:device
                                       withTexutrePath:modelTexturePath
                                 withCheckTransparency:checkTransparency
                                    withVerticesBuffer:model->Ptr()
                                            withLength:model->Length()
                                           withIndices:model->IndicesPtr()
                                            withLength:model->IndicesLength()];
    }
    
    return nil;
}


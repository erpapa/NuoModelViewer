//
//  NuoMatrixTypes.h
//  ModelViewer
//
//  Created by middleware on 2/3/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#ifndef NuoMatrixTypes_h
#define NuoMatrixTypes_h


/**
 *  Matrix/Vector types that cross the C++ and shader code
 *
 */


#ifndef Metal

#include "NuoMathVector.h"
#include <sys/types.h>

typedef NuoMatrixFloat44::_typeTrait::_matrixType matrix44;
typedef NuoMatrixFloat33::_typeTrait::_matrixType matrix33;
#define vector4 NuoVectorFloat4::_typeTrait::_vectorType
#define vector3 NuoVectorFloat3::_typeTrait::_vectorType
#define vector2 NuoVectorFloat2::_typeTrait::_vectorType

#else

#include <metal_stdlib>
#include <metal_matrix>

#define matrix44 metal::float4x4
#define matrix33 metal::float3x3
#define vector4 metal::float4
#define vector3 metal::float3
#define vector2 metal::float2

#endif


#endif /* NuoMatrixTypes_h */

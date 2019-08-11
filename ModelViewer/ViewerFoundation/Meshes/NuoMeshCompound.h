//
//  NuoMeshCompound.h
//  ModelViewer
//
//  Created by middleware on 5/18/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#import "NuoMesh.h"


@interface NuoMeshCompound : NuoMesh


@property (nonatomic, strong) NSArray<NuoMesh*>* meshes;


@end

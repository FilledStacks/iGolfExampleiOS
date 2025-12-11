//
//  Bunker3D.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@class Camera;
@class ElevationMap;
@class LayerPolygon;
@class Vector;

@interface Bunker3D : NSObject

@property (nonatomic, readonly) NSMutableArray* vertexList;
@property (nonatomic, readonly) NSMutableArray* uvList;
@property (nonatomic, readonly) NSMutableArray* indexList;
@property (nonatomic, readonly) NSMutableArray* normalList;
@property (nonatomic, readonly) NSArray<Vector*>* centrodList;
@property (nonatomic, readonly) LayerPolygon* border;

-(instancetype)initWithDictionary:(NSDictionary *)dict andElevationMap:(ElevationMap*)grid;
-(void)renderWithEffect:(GLKBaseEffect *)effect andCamera:(Camera*)camera andDepthFunc:(GLenum)depthFunc;
-(void)destroy;

@end

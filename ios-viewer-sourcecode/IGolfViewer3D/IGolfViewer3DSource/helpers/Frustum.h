//
//  Frustrum.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "../math/Vector.h"

@interface Frustum : NSObject

-(BOOL)isSphereVisibleWithX:(double)x andY:(double)y andZ:(double)z andR:(double)r;
-(void)updateFrustrumWithModelviewMatrix:(GLKMatrix4)modelviewMatrix andProjectionMatrix:(GLKMatrix4)projectionMatrix;
-(BOOL)isPointVisibleWithX:(double)x andY:(double)y andZ:(double)z;
-(BOOL)isVectorVisible:(Vector*)v;
-(BOOL)isCubeVisibleWithX:(double)x y:(double)y z:(double)z xSize:(double)xSize ySize:(double)ySize  zSize:(double)zSize;
-(BOOL)isVertexListVisible:(NSArray*)vertexList;
-(BOOL)isVectorListVisible:(NSArray<Vector*>*)vectorList;

@end

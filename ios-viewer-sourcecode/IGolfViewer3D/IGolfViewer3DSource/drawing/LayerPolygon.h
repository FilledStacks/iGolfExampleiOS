//
//  LayerPolygon.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"

@class Vector;
@class Frustum;

@interface LayerPolygon : NSObject

@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, readonly) Vector* extremeLeft;
@property (nonatomic, readonly) Vector* extremeTop;
@property (nonatomic, readonly) Vector* extremeRight;
@property (nonatomic, readonly) Vector* extremeBottom;
@property (nonatomic, readonly) NSArray<Vector*>* vectorArray;

-(id)initWithJsonObject:(NSDictionary *)jsonObject andTexture:(GLKTextureInfo *)texture andInterpolation:(unsigned int)interpolation andExtend:(double)extend;
- (void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum;
- (void)destroy;
- (BOOL)isInFrustum:(Frustum*)frustum;

@end

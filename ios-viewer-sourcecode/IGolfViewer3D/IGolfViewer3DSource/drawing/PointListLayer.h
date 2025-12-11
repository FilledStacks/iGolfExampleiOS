//
//  PointListLayer.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ElevationMap.h"

@class PointList;
@class Vector;

@interface PointListLayer : NSObject

@property (nonatomic, readonly) NSArray<PointList*>* pointList;
@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithJsonObject:(NSDictionary*)jsonObject andTransform:(BOOL)transform;
- (BOOL)containsWithVector:(Vector*)vector;
- (BOOL)isInFrustum:(Frustum *)frustum withGrid:(ElevationMap *)grid;
- (void)makeUnclosed;

@end

//
//  PointList.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ElevationMap.h"

@class Vector;

@interface PointList : NSObject

@property (nonatomic, assign) NSMutableArray<Vector*>* pointList;
@property (nonatomic, readonly) CGRect boundingBox;

- (id)initWithJsonObject:(NSDictionary*)jsonObject andTransform:(BOOL)transform;
- (void)reverse;
- (BOOL)containsWithVector:(Vector*)vector;
- (void)makeUnclosed;

@end

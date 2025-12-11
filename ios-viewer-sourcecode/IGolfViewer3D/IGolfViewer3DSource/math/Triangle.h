//
//  Triangle.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@class Ray;

@interface Triangle : NSObject

- (id)initWithV0:(float*)v0 andV1:(float*)v1 andV2:(float*)v2;

+ (int)intersectWithRay:(Ray*)R andTriangle:(Triangle*)T andI:(float*)Ival;

@end

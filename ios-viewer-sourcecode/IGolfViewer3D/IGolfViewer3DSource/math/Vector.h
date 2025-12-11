//
//  Vector.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Vector : NSObject

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;
@property (nonatomic, readonly) NSString* string;


- (BOOL)isEqualToVector:(Vector*)vector;
- (id)initWithX:(double)x andY:(double)y;
- (id)initWithVector:(Vector*)vector;
- (id)initWithX:(double)x andY:(double)y andZ:(double)z;
- (Vector*)substractedWithVector:(Vector*)vector;
- (Vector*)addedWithVector:(Vector*)vector;
- (Vector*)normalized;
- (Vector*)multipliedWithFactor:(double)factor;
- (Vector*)rotatedWithAngle:(double)angle;
- (double)distanceWithVector:(Vector*)vector;
- (BOOL)isInsideRect:(CGRect)rect;
    
@end

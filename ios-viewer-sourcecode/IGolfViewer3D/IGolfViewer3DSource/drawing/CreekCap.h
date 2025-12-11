//
//  CreekCap.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class Vector;

@interface CreekCap : NSObject

- (id)initWithPosition:(Vector*)position andRadius:(double)radius;
- (void)render;
- (void)destroy;

@end

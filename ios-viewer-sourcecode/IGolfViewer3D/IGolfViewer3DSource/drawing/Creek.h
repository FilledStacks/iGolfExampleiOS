//
//  Creek.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"
@class PointList;

@interface Creek : NSObject

- (id)initWithTextureFilename:(NSString*)textureFilename andPointList:(PointList*)pointList andWidth:(double)width;
- (void)renderWithEffect:(GLKBaseEffect*)effect;
- (void)destroy;

@end

//
//  Ground.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"

@interface Ground : NSObject

+ (double)SceneRadius;
+ (double)SceneAngleStepDegrees;

- (id)initWith2DTextureFilePath:(NSString*)textureFilePath2d and3DTextureFilePath:(NSString*)textureFilePath3d andFlyoverTextureFilePath:(NSString*)flyoverTextureFilePath;
- (void)destroy;
- (void)renderWithEffect:(GLKBaseEffect *)effect using2DTexture:(BOOL)texture2d isFlyover:(BOOL)isFlyover;

@end

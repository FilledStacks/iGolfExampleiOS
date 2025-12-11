//
//  Cart.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"

@class CLLocation;
@class Camera;

@interface Cart : NSObject

@property (nonatomic, retain) CLLocation* location;

- (id)initWithTextureFilename:(NSString*)textureFilename andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationMap:(ElevationMap*)grid;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;


@end

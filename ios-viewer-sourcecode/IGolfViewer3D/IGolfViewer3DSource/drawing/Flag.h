//
//  Flag.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"
#import <CoreLocation/CoreLocation.h>

@class Vector;
@class Camera;

@interface Flag : NSObject

+(Flag*)INSTANCE;

@property (nonatomic, retain) Vector* flagPosition;
@property (nonatomic, readonly) CLLocation* location;

- (id)initWithTextureFilename:(NSString *)textureFilename andPosition:(Vector *)position andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)calculateMatricesWithCamera:(Camera*)camera;
- (double)zPosition;

@end

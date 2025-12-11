//
//  Callouts.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ElevationMap.h"


@class PointListLayer;
@class Camera;
@class Vector;

@interface LineToFlag : NSObject

@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, retain) PointListLayer* centralPath;
@property (nonatomic, readonly) BOOL hasFocus;
@property (nonatomic, readonly) Vector* startLocation;
@property (nonatomic, readonly) Vector* endLocation;

- (id)initWithLocationTextureFilePath:(NSString*)locationTexture andElevationGrid:(ElevationMap *)grid andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer;
- (CLLocation*)startPointLocation;
- (CLLocation*)endPointLocation;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (BOOL)onTouchDown:(CGPoint)point andCamera:(Camera*)camera;
- (BOOL)onTouchMove:(Vector*)coordinate;
- (BOOL)onTouchUp:(Vector*)coordinate;
- (void)destroy;
- (void)resetPosition;

@end

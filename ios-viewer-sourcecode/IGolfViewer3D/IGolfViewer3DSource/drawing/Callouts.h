//
//  Callouts.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"
#import "CalloutsDrawMode.h"
#import "MeasurementSystem.h"


@class PointListLayer;
@class Camera;
@class Vector;

@interface Callouts : NSObject

@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, assign) CalloutsDrawMode calloutsDrawMode;
@property (nonatomic, retain) PointListLayer* centralPath;
@property (nonatomic, readonly) BOOL hasFocus;
@property (nonatomic, assign) BOOL showOverlay;
@property (nonatomic, assign) MeasurementSystem measurementSystem;
@property (nonatomic, readonly) Vector* startLocation;
@property (nonatomic, readonly) Vector* endLocation;

- (id)initWithLocationTextureFilePath:(NSString*)locationTexture andEndLocationTexture:(NSString*) endLocationTexture andCursorTextureFilePath:(NSString*)cursorTexture andVertexbuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer;
- (CLLocation*)startPointLocation;
- (CLLocation*)endPointLocation;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (BOOL)onTouchDown:(Vector*)coordinate andCamera:(Camera*)camera;
- (BOOL)onTouchMove:(Vector*)coordinate;
- (BOOL)onTouchUp:(Vector*)coordinate;
- (void)destroy;
- (void)resetPosition;
- (void)setCentralPath:(PointListLayer *)centralPath andDogLegLocation:(CLLocation *)currentLocation;


@end

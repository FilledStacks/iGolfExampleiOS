//
//  DistanceMarker.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "../IGolfViewer3DPrivateImports.h"
#import "MeasurementSystem.h"

@class CLLocation;
@class Camera;
@class Vector;

@interface DistanceMarker : NSObject

@property (nonatomic, readonly) double zPosition;
@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, retain) Vector* projectedPosition;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, assign) MeasurementSystem measurementSystem;
@property (nonatomic, readonly) Vector* markerPosition;
@property (nonatomic, readonly) Vector* markerOriginalPosition;


-(id)initWithGroundTextureFilename:(NSString *)groundTextureFilename andCalloutTextureFileName:(NSString*)calloutTextureFileName andtexture2DFileName:(NSString*) texture2DFileName andLocation:(CLLocation *)location andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationGrid:(ElevationMap *)grid andMarkerType: (int) type;
- (void)scaleByPositionWithAdditionalScale:(double)scale;
- (void)setScale:(double)scale;
- (void)calculateMatricesWithCamera:(Camera*)camera;
- (void)renderGroundMarkerWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)destroy;
- (void)renderGroundMarkerForPosition:(Vector *)position andEffect:(GLKBaseEffect*)effect;
- (BOOL)hasGroundMarker;
- (void)restoreOriginalLocation;
- (void)updateMarkerLocation:(CLLocation *) location;
@end

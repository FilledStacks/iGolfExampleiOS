//
//  DistanceMarker3D.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "MeasurementSystem.h"
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"

@class CLLocation;
@class Camera;
@class Vector;

NS_ASSUME_NONNULL_BEGIN

@interface DistanceMarker3D : NSObject

@property (nonatomic, readonly) double zPosition;
@property (nonatomic, retain) Vector* projectedPosition;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, assign) MeasurementSystem measurementSystem;
@property (nonatomic, readonly) Vector* markerPosition;


-(id)initWithGroundTextureFilename:(NSString *)groundTextureFilename andLocation:(CLLocation *)location andVertexBuffer:(GLuint)vertexBuffer andUVBuffer:(GLuint)uvBuffer andElevationGrid:(ElevationMap *)grid;
- (void)setCenterLocation:(CLLocation *)centerLocation andCurrentLocation:(CLLocation *)currentLocation;
- (void)scaleByPositionWithAdditionalScale:(double)scale;
- (void)setScale:(double)scale;
- (void)calculateMatricesWithCamera:(Camera*)camera;
- (void)renderGroundMarkerWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)renderWithEffect:(GLKBaseEffect*)effect andCamera:(Camera*)camera;
- (void)destroy;
- (void)renderGroundMarkerForPosition:(Vector *)position andEffect:(GLKBaseEffect*)effect;
- (BOOL)hasGroundMarker;
@end

NS_ASSUME_NONNULL_END

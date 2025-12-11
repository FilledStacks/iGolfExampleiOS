//
//  Camera.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>

#import "../IGolfViewer3DPrivateImports.h"
#import "NavigationMode.h"
#import "../CameraDelegate.h"



@class PointListLayer;
@class Vector;
@class Callouts;
@class LineToFlag;
@class DistanceMarker;
@class Layer;
@class ElevationMap;
@class Frustum;

@interface Camera : NSObject

@property (nonatomic, assign) double diffuseColor;
@property (nonatomic, assign) double specularColor;
@property (nonatomic, assign) double ambientColor;

@property (nonatomic, retain) NSDate* lastZoomDate;
@property (nonatomic, assign) CGRect viewport;
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;
@property (nonatomic, assign) double viewAngle;
@property (nonatomic, assign) double rotationAngle;
@property (nonatomic, readonly) GLKMatrix4 projectionMatrix;
@property (nonatomic, readonly) GLKMatrix4 modelViewMatrix;
@property (nonatomic, readonly) GLKMatrix4 intersectionUnprojectionMatrix;
@property (nonatomic, assign) CGPoint gesturePan;
@property (nonatomic, assign) double gestureRotation;
@property (nonatomic, assign) double gestureZoom;
@property (nonatomic, retain) PointListLayer* centralPath;
@property (nonatomic, assign) NavigationMode navigationMode;
@property (nonatomic, retain) Callouts* callouts;
@property (nonatomic, retain) LineToFlag* lineToFlag;
@property (nonatomic, readonly) BOOL currentLocationVisible;
@property (nonatomic, readonly) BOOL rotateHoleOnLocationChanged;
@property (nonatomic, retain) DistanceMarker* frontGreenMarker;
@property (nonatomic, retain) DistanceMarker* backGreenMarker;
@property (nonatomic, retain) Layer* greenLayer;
@property (nonatomic, retain) Layer* teeBoxLayer;
@property (nonatomic, retain) Layer* perimeterLayer;
@property (nonatomic, retain) PointListLayer* perimeterPointListLayer;
@property (nonatomic, retain) PointListLayer* fairwayPointListLayer;
@property (nonatomic, assign) int parValue;
@property (nonatomic, assign) double overallHoleViewAngle;
@property (nonatomic, assign) double freeCamViewAngle;
@property (nonatomic, assign) double greenViewViewAngle;
@property (nonatomic, assign) double flyoverViewAngle;
@property (nonatomic, readonly) Frustum* frustum;
@property (nonatomic, readonly) BOOL isAutozoomActive;
@property (nonatomic, weak) id <CameraDelegate> delegate;
@property (nonatomic, assign) CLLocation* location;
@property (nonatomic, readonly) Vector* cameraPoint;
@property (nonatomic, readonly) float viewportXOffset;

+ (double)autoZoomPeriod;
- (id)initWithView:(UIView *)view andAutoZoomActive:(BOOL)isActive andElevationMap:(ElevationMap*)grid andFinalPosition:(Vector*)position andRotateHoleOnLocationChanged:(BOOL) rotateHoleOnLocationChanged;
- (void)endPan;
- (void)endRotation;
- (void)endZoom;
- (BOOL)isFlyover;
- (void)tickWithCallback:(BOOL)withCallback andEffect:(GLKBaseEffect*)effect;
- (NSDate*)getLastZoomDate;
- (Vector*)unprojectWithTouchPoint:(CGPoint)point;
- (NSArray<Vector*>*)unprojectViewport;
- (void)applyZoomWithCustomTapPoint:(CGPoint)point;
- (void)setAutoZoomActive:(BOOL)isActive;
- (void)setRotateHoleOnLocationChanged:(BOOL)rotateHoleOnLocationChanged;
- (Vector*)calculateTouchPoint:(CGPoint)point;
- (void)prepareFlyoverParameters;
- (CGRect)getViewport;
- (void)updateLastZoomDate;
- (void)updateFrustum;
- (void)update3DFreeCamPosition;
- (Vector*)getCameraProjectionPoint;
- (NSString*)getProtectionCode;
- (void)requestRedrawingTiles;
- (void)update3DGreenViewPosition;
- (void)update2DGreenViewPosition;
- (void)update2DPosition;
- (void)updateViewportAndProjectionMatrix:(UIView *)view andRenderWidthPercent:(float)renderViewWidthPercent;

@end

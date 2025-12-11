//
//  FlyoverController.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import "AnimationState.h"
#import "CentralPathCleaner.h"

@class PointListLayer;
@class Vector;
@class CentralPathCleaner;

@interface FlyoverController : NSObject

@property (nonatomic, retain) PointListLayer* centralPath;
@property (nonatomic, assign) double defaultViewAngle;
@property (nonatomic, readonly) Vector* position;
@property (nonatomic, readonly) double rotationAngle;
@property (nonatomic, readonly) double viewAngle;
@property (nonatomic, assign) double defaultZoom;
@property (nonatomic, assign) double endZoom;
@property (nonatomic, assign) double zoomSpeed;
@property (nonatomic, readonly) double zoom;
@property (nonatomic, readonly) BOOL finished;

- (void)start;
- (void)tick;
- (void)pause;
- (void)resume;
- (void)testTick;
- (double)getCompletePercentage;
- (void)setCleaner:(CentralPathCleaner*)cleaner;
- (AnimationState)getAnimationState;

@end

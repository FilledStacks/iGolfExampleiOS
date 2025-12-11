//
//  Layer.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "../IGolfViewer3DPrivateImports.h"
#import "IDrawable.h"

#define METERS_IN_POINT   0.05

@class Vector;
@class LayerPolygon;
@class Elevation;
@interface Layer : NSObject<IDrawable>

@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, readonly) Vector* extremeLeft;
@property (nonatomic, readonly) Vector* extremeTop;
@property (nonatomic, readonly) Vector* extremeRight;
@property (nonatomic, readonly) Vector* extremeBottom;
@property (nonatomic, readonly) Vector* centroid;
@property (nonatomic, readonly) NSArray<LayerPolygon*>* layerPolygons;
@property (nonatomic, readonly) double pointsInMeter;

+ (double)transformLonFromString:(NSString*)lon;
+ (double)transformLonFromDouble:(double)lon;
+ (double)transformLatFromString:(NSString*)lat;
+ (double)transformLatFromDouble:(double)lat;
+ (double)transformToLonWithDouble:(double)lon;
+ (double)transformToLatWithDouble:(double)lat;
+ (void)resetBaseValues;
+ (void)setBaseLatitude:(double)lat andBaseLongitude:(double)lon;
-(id)initWithJsonObject:(NSDictionary *)jsonObject andFilePath:(NSString *)filePath andInterpolation:(int)interpolation andExtend:(double)extend;
- (void)renderWithEffect:(GLKBaseEffect*)effect andFrustum:(Frustum*)frustum;
- (void)disableDrawing;
- (void)enableDrawing;
- (void)destroy;
- (BOOL)isDrawingEnabled;
- (BOOL)isWaterLayer;
- (BOOL)isInFrustum:(Frustum*)frustum;
- (BOOL)isInFrustum:(Frustum*)frustum withGrid:(ElevationMap*)grid;
+ (double)getMetersInOneLongitudeDegreeWithLatitude:(double)latitude;
+ (double)getMetersInOneLatitudeDegree;
-(Vector*) getRotatedLayerCenterWithPivot:(Vector*) pivot andAngleDegrees:(double) angleDegrees;
- (NSMutableArray<Vector*>*) getExtremeBox;
-(Vector*) getCenter;

@end

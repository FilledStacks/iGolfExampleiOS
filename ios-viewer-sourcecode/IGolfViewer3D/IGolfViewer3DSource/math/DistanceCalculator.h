//
//  DistanceCalculator.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MeasurementSystem.h"

@interface DistanceCalculator : NSObject

+ (double)distanceWithWorldX1:(double)x1 andWorldY1:(double)y1 andWorldX2:(double)x2 andWorldY2:(double)y2 andMeasurementSystem:(MeasurementSystem)measurementSystem;
+ (double)distanceWithLocation1:(CLLocation*)location1 andLocation2:(CLLocation*)location2 andMEasurementSystem:(MeasurementSystem)measurementSystem;
+ (double)metricToImerial:(double)value;

@end

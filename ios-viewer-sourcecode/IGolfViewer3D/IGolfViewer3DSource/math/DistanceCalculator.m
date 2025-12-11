//
//  DistanceCalculator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "DistanceCalculator.h"
#import "../IGolfViewer3DPrivateImports.h"

@implementation DistanceCalculator

+ (double)distanceWithWorldX1:(double)x1 andWorldY1:(double)y1 andWorldX2:(double)x2 andWorldY2:(double)y2 andMeasurementSystem:(MeasurementSystem)measurementSystem {

    CLLocation* start = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:y1] longitude:[Layer transformToLonWithDouble:x1]];
    CLLocation* end = [[CLLocation alloc] initWithLatitude:[Layer transformToLatWithDouble:y2] longitude:[Layer transformToLonWithDouble:x2]];

    double distance = [start distanceFromLocation:end];
    
    if (measurementSystem == MeasurementSystemImperial) {
        distance = [DistanceCalculator metricToImerial:distance];
    }
    
    return distance;
}

+ (double)distanceWithLocation1:(CLLocation*)location1 andLocation2:(CLLocation*)location2 andMEasurementSystem:(MeasurementSystem)measurementSystem {
    
    double distance = [location1 distanceFromLocation:location2];
    
    if (measurementSystem == MeasurementSystemImperial) {
        distance = [self metricToImerial:distance];
    }
    
    return distance;
}

+ (double)metricToImerial:(double)value {

    return value * 1.0936;;
}

@end

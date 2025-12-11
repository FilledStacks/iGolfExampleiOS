//
//  CourseDistanceMeasurer.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseDistanceMeasurer.h"
#import "CourseHole.h"
#import "../IGolfViewer3DPrivateImports.h"


@interface CourseDistanceMeasurer() {
    
    __weak id <CourseDistanceMeasurerDelegate> _delegate;
    NSArray<CourseHole *>* _holes;
    CLLocation* _currentLocation;
    NSUInteger _currentHole;
    MeasurementSystem _measurementSystem;
}

@end

@implementation CourseDistanceMeasurer

-(id)initWithGPSDetailsData:(NSArray *)gpsDetailsData measurementSystem:(MeasurementSystem)measurementSystem {
    
    self = [super init];
    
    if (self) {
        
        NSMutableArray<CourseHole *>* courseHoles = [NSMutableArray new];
        
        for (NSDictionary* dict in gpsDetailsData) {
            [courseHoles addObject:[[CourseHole alloc] initWithDict:dict]];
        }
        
        self->_holes = courseHoles;
        self->_measurementSystem = measurementSystem;
    }
    
    return self;
}

-(void)setCurrentLocation:(CLLocation *)currentLocation {
    
    _currentLocation = currentLocation;
    
    [self sendDistances];
}

-(void)setCurrentHole:(NSUInteger)currentHole {
    
    _currentHole = currentHole;
    
    [self sendDistances];
}

-(void)setMeasurementSystem:(MeasurementSystem)measurementSystem {
    
    _measurementSystem = measurementSystem;
    
    [self sendDistances];
}

-(void)sendDistances {
    
    CourseHole* hole = [self getHole];
    
    if (hole != nil && _currentLocation != nil) {
        [_delegate courseDistanceMeasurerDidUpdateDistancesToFrontGreen:[self distanceWithLocation1:_currentLocation andLocation2:hole.frontLocation]
                                                          toCenterGreen:[self distanceWithLocation1:_currentLocation andLocation2:hole.centerLocation]
                                                            toBackGreen:[self distanceWithLocation1:_currentLocation andLocation2:hole.backLocation]];
    }
    
}

-(nullable CourseHole*)getHole {
    
    for (CourseHole* hole in _holes) {
        if (hole.holeNumber == _currentHole) {
            return hole;
        }
    }
    
    return nil;
}

-(double)distanceWithLocation1:(CLLocation*)location1 andLocation2:(CLLocation*)location2 {
    
    double distance = [location1 distanceFromLocation:location2];
    
    if (_measurementSystem == MeasurementSystemImperial) {
        distance = [self metricToImerial:distance];
    }
    
    distance = round(distance);
    distance = MIN(999.0, distance);
    
    return distance;
}

-(double)metricToImerial:(double)value {
    
    return value * 1.0936;
}

-(id<CourseDistanceMeasurerDelegate>)delegate {
    
    return _delegate;
}

-(void)setDelegate:(id<CourseDistanceMeasurerDelegate>)delegate {
    
    self->_delegate = delegate;
    
    [self sendDistances];
}

@end

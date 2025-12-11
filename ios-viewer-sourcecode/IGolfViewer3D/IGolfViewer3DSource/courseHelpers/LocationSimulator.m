//
//  LocationSimulator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "LocationSimulator.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationSimulator() {
    
    MKPolygon* _coursePolygon;
    MKPolygonRenderer* _renderer;
    NSArray<NSNumber*>* _ydsHoleList;
    NSArray* _gpsList;
}

@end

@implementation LocationSimulator

-(id)initWithGpsVectorData:(NSDictionary*)gpsVectorData andGPSList:(NSArray*)gpsList andTeesObject:(NSDictionary*)teesObject {
    self = [super init];
    
    if (self) {
        self->_coursePolygon = [self getCoursePolygonWith:gpsVectorData];
        self->_renderer = [[MKPolygonRenderer alloc] initWithPolygon:_coursePolygon];
        self->_ydsHoleList = [teesObject valueForKey:@"ydsHole"];
        self->_gpsList = gpsList;
    }
    
    return self;
}

-(CLLocation*)getLocationForHole:(NSUInteger)hole {
    
    int holeIndex = (int)hole - 1;
    int yardage = [self getYdsForHoleIndex:holeIndex];
    
    CLLocation* centerLocation = [self getCenterGreenLocationForHoleIndex:holeIndex];
    NSArray<CLLocation*>* teeBoxesLocationList = [self getTeeBoxesLocationListForHoleIndex:holeIndex];
    CLLocation* firstLocation = teeBoxesLocationList.firstObject;
    CLLocation* bestLocation = firstLocation;
    
    double minDelta = fabs([firstLocation distanceFromLocation:centerLocation] * 1.09361 - (double)yardage);

    for (int i = 1; i < teeBoxesLocationList.count; i ++) {
        CLLocation* location = [teeBoxesLocationList objectAtIndex:i];
        
        double delta = fabs([location distanceFromLocation:centerLocation] * 1.09361 - (double)yardage);
        
        if (delta < minDelta) {
            minDelta = delta;
            bestLocation = location;
        }
    }
    
    return bestLocation;
}

-(BOOL)coursePolygonContainsLocation:(CLLocation*)location {
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);
    CGPoint viewPoint = [_renderer pointForMapPoint:mapPoint];
    
    return CGPathContainsPoint(_renderer.path, nil, viewPoint, true);
}

-(MKPolygon*)getCoursePolygonWith:(NSDictionary*)gpsVectorData {
    
    NSDictionary* backgroundDict = [gpsVectorData valueForKey:@"Background"];
    NSDictionary* shapes = [backgroundDict valueForKey:@"Shapes"];
    NSArray* shape = [shapes valueForKey:@"Shape"];
    NSDictionary* shapeDict = [shape firstObject];
    NSString* points = [shapeDict valueForKey:@"Points"];
    NSArray<NSString*>* lonLanPairs = [points componentsSeparatedByString:@","];
    
    CLLocationCoordinate2D coords[lonLanPairs.count];

    for (int i = 0; i < lonLanPairs.count; i++) {
        
        NSString* pair = [lonLanPairs objectAtIndex:i];
        NSArray<NSString*>* lonLatPair = [pair componentsSeparatedByString:@" "];
        double lon = [lonLatPair.firstObject doubleValue];
        double lat = [lonLatPair.lastObject doubleValue];
        coords[i] = CLLocationCoordinate2DMake(lat, lon);
    }
    
    return [MKPolygon polygonWithCoordinates:coords count:lonLanPairs.count];
}

-(int)getYdsForHoleIndex:(int)holeIndex {
    
    if (holeIndex < _ydsHoleList.count && holeIndex >= 0) {
        return [[_ydsHoleList objectAtIndex:holeIndex] intValue];
    } else {
        return -1;
    }
}

-(nullable CLLocation*)getCenterGreenLocationForHoleIndex:(int)holeIndex {
    
    if (holeIndex < _gpsList.count && holeIndex >= 0) {
        
        NSDictionary* dict = [_gpsList objectAtIndex:holeIndex];
        
        double centerLat = [[dict valueForKey:@"centerLat"] doubleValue];
        double centerLon = [[dict valueForKey:@"centerLon"] doubleValue];
        
        return [[CLLocation alloc] initWithLatitude:centerLat longitude:centerLon];
    }

    return nil;
}

-(NSArray<CLLocation*>*)getTeeBoxesLocationListForHoleIndex:(int)holeIndex {
    
    NSMutableArray<CLLocation*>* retval = [NSMutableArray new];
    
    if (holeIndex < _gpsList.count && holeIndex >= 0) {
        
        NSDictionary* dict = [_gpsList objectAtIndex:holeIndex];
        
        for (int i = 1; i <= 5; i++) {
            NSString* latKey = [NSString stringWithFormat:@"teeLat%d", i];
            NSString* lonKey = [NSString stringWithFormat:@"teeLon%d", i];
            double teeLat = [[dict valueForKey:latKey] doubleValue];
            double teeLon = [[dict valueForKey:lonKey] doubleValue];
            [retval addObject:[[CLLocation alloc]initWithLatitude:teeLat longitude:teeLon]];
        }
    }
    
    return retval;
}


@end

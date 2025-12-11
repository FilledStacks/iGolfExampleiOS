//
//  CentralPathCleaner.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CentralPathCleaner.h"
#import <MapKit/MapKit.h>

@interface CentralPathCleaner() {
    Layer* _greenViewLayer;
    NSArray<Vector*>* _centralPathPoints;
    MKPolygon* _polygon;
    MKPolygonRenderer* _renderer;
}
@end


@implementation CentralPathCleaner

-(instancetype)initWithGreenView:(Layer *)greenViewLayer {
    self = [super init];
    
    if (self) {
        self->_greenViewLayer = greenViewLayer;
        [self processData];
    }
    
    return self;
}

-(void)processData {
    
    NSMutableArray<Vector*>* points = [NSMutableArray new];
    
    [points addObject:_greenViewLayer.extremeLeft];
    [points addObject:_greenViewLayer.extremeBottom];
    [points addObject:_greenViewLayer.extremeRight];
    [points addObject:_greenViewLayer.extremeTop];
    [points addObject:_greenViewLayer.extremeLeft];
    
    NSArray<Vector*>* interpolatedPoints = [Interpolator interpolateWithCoordinateArray:points andPointsPerSegment:5 andCurveType:CatmullRomTypeCentripetal];
    
    int count = (int)interpolatedPoints.count;
    
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        
        Vector* v = [interpolatedPoints objectAtIndex:i];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([Layer transformToLatWithDouble:v.y], [Layer transformToLonWithDouble:v.x]);
        
        coords[i] = coord;
    }
    
    _polygon = [MKPolygon polygonWithCoordinates:coords count:count];
    
    _renderer = [[MKPolygonRenderer alloc] initWithPolygon:_polygon];
}

-(NSArray<Vector*>*)cleanCentralPath:(NSArray<Vector*>*)centralPath {
    NSMutableArray<Vector*>* cleaned = [NSMutableArray new];
    
    if (centralPath.count <= 2) {
        return centralPath;
    }
    
    [cleaned addObject:centralPath.firstObject];
    
    for (int i = 1; i <= centralPath.count - 2; i++) {
        
        Vector* point = [centralPath objectAtIndex:i];
        
        if (![self isPointInPolygon:point]) {
            [cleaned addObject:point];
        }
    }
    
    [cleaned addObject:centralPath.lastObject];
    
    return cleaned;
    
}

-(BOOL)isPointInPolygon:(Vector*)point {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([Layer transformToLatWithDouble:point.y], [Layer transformToLonWithDouble:point.x]);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    CGPoint viewPoint = [_renderer pointForMapPoint:mapPoint];
    return CGPathContainsPoint(_renderer.path, NULL, viewPoint, true);
}

@end

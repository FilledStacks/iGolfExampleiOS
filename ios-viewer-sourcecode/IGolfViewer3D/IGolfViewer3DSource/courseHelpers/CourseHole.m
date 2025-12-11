//
//  CourseHole.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "CourseHole.h"
#import <CoreLocation/CoreLocation.h>

@interface CourseHole() {
    
    CLLocation* _centerLocation;
    CLLocation* _frontLocation;
    CLLocation* _backLocation;
    
    NSUInteger _holeNumber;
}

@end

@implementation CourseHole

-(id)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    
    if (self) {
        
        self->_holeNumber = [[dict valueForKey:@"holeNumber"] unsignedIntegerValue];
        
        self->_centerLocation = [[CLLocation alloc] initWithLatitude:[[dict valueForKey:@"centerLat"] doubleValue]
                                                           longitude:[[dict valueForKey:@"centerLon"] doubleValue]];
        self->_frontLocation = [[CLLocation alloc] initWithLatitude:[[dict valueForKey:@"frontLat"] doubleValue]
                                                          longitude:[[dict valueForKey:@"frontLon"] doubleValue]];
        self->_backLocation = [[CLLocation alloc] initWithLatitude:[[dict valueForKey:@"backLat"] doubleValue]
                                                         longitude:[[dict valueForKey:@"backLon"] doubleValue]];
    }
    
    return self;
}

-(NSUInteger)holeNumber {
    return _holeNumber;
}

-(CLLocation *)centerLocation {
    return _centerLocation;
}

-(CLLocation *)frontLocation {
    return _frontLocation;
}

-(CLLocation *)backLocation {
    return _backLocation;
}

@end

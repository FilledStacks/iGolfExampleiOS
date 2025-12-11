//
//  PinPosition.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <CoreLocation/CoreLocation.h>
#import "PinPosition.h"
#import "IGolfViewer3DPrivateImports.h"


@interface PinPosition() {
    CLLocation* _location;
    Vector* _position;
    NSDate* _date;
    NSUInteger _holeNumber;
}

@end

@implementation PinPosition

-(instancetype)initForHole:(NSUInteger)holeNumber withDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        if ([dictionary  objectForKey:@"latitude"] == nil || [dictionary  objectForKey:@"longitude"] || [dictionary  objectForKey:@"date"] == nil) {
            return nil;
        }
        
        double lat = [[dictionary  objectForKey:@"latitude"] doubleValue];
        double lon = [[dictionary  objectForKey:@"longitude"] doubleValue];
        
        double x = [Layer transformLonFromDouble:lon];
        double y = [Layer transformLatFromDouble:lat];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-dd";
        
        NSString* dateString = [dictionary  valueForKey:@"date"];
        
        self->_date = [formatter dateFromString:dateString];
        self->_position = [[Vector alloc] initWithX:x andY: y];
        self->_holeNumber = holeNumber;
        self->_location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    
    return self;
}

-(Vector *)position {
    return _position;
}

-(NSDate *)date {
    return _date;
}

-(NSUInteger)holeNumber {
    return _holeNumber;
}

-(CLLocation *)location {
    return _location;
}

@end

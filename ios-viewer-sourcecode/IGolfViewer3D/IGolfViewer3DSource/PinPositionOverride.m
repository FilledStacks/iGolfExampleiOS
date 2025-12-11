//
//  PinPositionOverride.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "PinPositionOverride.h"
#import "PinPosition.h"
#import <CoreLocation/CoreLocation.h>

@interface PinPositionOverride() {
    
    NSMutableArray<PinPosition*>* _pins;
    
}

@end

@implementation PinPositionOverride



- (instancetype)initWithData:(NSArray*) data {
    self = [super init];
    if (self) {
        self->_pins = [NSMutableArray new];
        
        for (NSDictionary* dict in data) {
            
            NSUInteger holeNumber = [[dict objectForKey:@"holeNumber"] unsignedIntegerValue];
            NSArray* positions = [dict valueForKey:@"positions"];
            NSDictionary* pinDictionary = [positions objectAtIndex:0];
            
            
            
            PinPosition* pin = [[PinPosition alloc] initForHole:holeNumber withDictionary:pinDictionary];
            
            if (pin != nil) {
                [_pins addObject: pin];
            }
        }
    }
    
    return self;
}


-(Vector *)getPositionForHole:(NSUInteger)holeNumber {
    for (PinPosition* pin in _pins) {
        if (pin.holeNumber == holeNumber) {
            NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
            
            if ([calendar isDateInToday:pin.date]) {
                return  pin.position;
            }
        }
    }

    return nil;
}

-(CLLocation *)getLocationForHole:(NSUInteger)holeNumber {
    for (PinPosition* pin in _pins) {
        if (pin.holeNumber == holeNumber) {
            NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
            if ([calendar isDateInToday:pin.date]) {
                return  pin.location;
            }
        }
    }
    
    return nil;
}

@end



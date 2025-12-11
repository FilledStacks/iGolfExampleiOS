//
//  PinPositionOverride.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IGolfViewer3DPrivateImports.h"

@interface PinPositionOverride : NSObject

-(instancetype)initWithData:(NSArray*)data;

-(Vector*) getPositionForHole:(NSUInteger) holeNumber;
-(CLLocation*) getLocationForHole:(NSUInteger) holeNumber;

@end

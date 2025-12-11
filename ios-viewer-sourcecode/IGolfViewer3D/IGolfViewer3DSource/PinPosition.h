//
//  PinPosition.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IGolfViewer3DPrivateImports.h"

@interface PinPosition : NSObject

@property (nonatomic, readonly) Vector* position;
@property (nonatomic, readonly) NSDate* date;
@property (nonatomic, readonly) NSUInteger holeNumber;
@property (nonatomic, readonly) CLLocation* location;

-(instancetype) initForHole:(NSUInteger)holeNumber withDictionary:(NSDictionary *)dictionary;

@end

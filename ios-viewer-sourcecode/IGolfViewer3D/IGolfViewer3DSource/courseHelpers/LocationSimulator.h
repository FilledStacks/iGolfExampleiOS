//
//  LocationSimulator.h
//  iGolfViewer3D
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationSimulator : NSObject

-(id)initWithGpsVectorData:(NSDictionary*)gpsVectorData andGPSList:(NSArray*)gpsList andTeesObject:(NSDictionary*)teesObject;
-(CLLocation*)getLocationForHole:(NSUInteger)hole;
-(BOOL)coursePolygonContainsLocation:(CLLocation*)location;

@end

NS_ASSUME_NONNULL_END

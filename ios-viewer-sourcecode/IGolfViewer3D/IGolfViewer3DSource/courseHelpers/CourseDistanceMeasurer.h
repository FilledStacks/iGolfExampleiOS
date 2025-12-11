//
//  CourseDistanceMeasurer.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MeasurementSystem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CourseDistanceMeasurerDelegate <NSObject>

@optional

- (void)courseDistanceMeasurerDidUpdateDistancesToFrontGreen:(double)frontGreen
                                               toCenterGreen:(double)centerGreen
                                                 toBackGreen:(double)backGreen;

@end

@interface CourseDistanceMeasurer : NSObject

@property (nonatomic, weak) id <CourseDistanceMeasurerDelegate> delegate;
@property (nonatomic, assign) MeasurementSystem measurementSystem;
@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, assign) NSUInteger currentHole;

-(id)initWithGPSDetailsData:(NSArray *)gpsDetailsData measurementSystem:(MeasurementSystem)measurementSystem;

@end

NS_ASSUME_NONNULL_END

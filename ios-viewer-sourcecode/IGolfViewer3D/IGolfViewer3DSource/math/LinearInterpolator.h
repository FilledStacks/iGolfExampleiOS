//
//  LinearInterpolator.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@interface LinearInterpolator : NSObject

@property (nonatomic, assign) double startValue;
@property (nonatomic, assign) double endValue;
@property (nonatomic, assign) double speed;
@property (nonatomic, readonly) double currentValue;
@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) double completedPercentage;

- (void)start;
- (void)tickWithTimeElapsed:(int)timeElapsed;
- (double)valueAtCompletedPercentage:(double)completedPercentage;

@end

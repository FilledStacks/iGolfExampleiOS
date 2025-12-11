//
//  RotationHelper.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@interface RotationHelper : NSObject

@property (nonatomic, assign) double endValue;
@property (nonatomic, readonly) double currentValue;
@property (nonatomic, assign) double speed;

- (void)tickWithTimeElapsed:(int)timeElapsed;

@end

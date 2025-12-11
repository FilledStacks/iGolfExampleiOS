//
//  WaitFunction.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@interface WaitFunction : NSObject

@property (nonatomic, assign) double waitTime;
@property (nonatomic, readonly) BOOL finished;

- (void)start;
- (void)tickWithTimeElapsed:(int)timeElapsed;

@end

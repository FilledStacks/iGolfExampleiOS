//
//  ElapsedTimeCalculator.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@interface ElapsedTimeCalculator : NSObject

@property (nonatomic, readonly) int timeElapsedInt;

- (void)tick;
- (void)pause;
- (void)resume;
- (BOOL)isPaused;
@end

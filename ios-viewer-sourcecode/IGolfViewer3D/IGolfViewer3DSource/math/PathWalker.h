//
//  PathWalker.h
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import <Foundation/Foundation.h>

@class Vector;

@interface PathWalker : NSObject

@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) Vector* position;
@property (nonatomic, readonly) double angle;
@property (nonatomic, retain) NSArray<Vector*>* path;
@property (nonatomic, assign) double speed;

- (void)start;
- (double)getCompletePercentage;
- (void)tickWithTimeElapsed:(int)timeElapsed;

@end

//
//  Profiler.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "Profiler.h"

@interface Profiler () {
    long long timeStart;
}

@end

@implementation Profiler


- (id)init {

    self = [super init];

    if (self) {
        self->timeStart = [self getCurrentTimeMillis];
    }
    
    return self;
}

- (void)stopWithMessage:(NSString*)message {

//    long long timeElapsed = [self getCurrentTimeMillis] - timeStart;
//    NSLog(@"%@ %lld ms", message, timeElapsed);
}


- (long long)getCurrentTimeMillis {

    return [[NSDate new] timeIntervalSince1970] * 1000;
}

@end

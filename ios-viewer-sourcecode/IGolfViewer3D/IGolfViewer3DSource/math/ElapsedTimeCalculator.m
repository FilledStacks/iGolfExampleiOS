//
//  ElapsedTimeCalculator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "ElapsedTimeCalculator.h"


@interface ElapsedTimeCalculator () {
    long long _lastTimeMillis;
    long _timeElapsed;
    bool _isPaused;
}

@end

@implementation ElapsedTimeCalculator


- (void)pause {
    if (_isPaused == true) {
        return;
    }
    _isPaused = true;
}

- (void)resume {
    if (_isPaused == false) {
        return;
    }
    
    _timeElapsed = 0;
    _lastTimeMillis = [self getCurrentTimeMillis];
    _isPaused = false;
    
}

-(BOOL)isPaused {
    return  _isPaused;
}

- (int)timeElapsedInt {
    return (int)_timeElapsed;
}

- (void)tick {

    long long currentTimeMillis = [self getCurrentTimeMillis];

    if (_lastTimeMillis != 0) {
        _timeElapsed = currentTimeMillis - _lastTimeMillis;
    }

    _lastTimeMillis = currentTimeMillis;
}

- (long long)getCurrentTimeMillis {
    return [[NSDate new] timeIntervalSince1970] * 1000;
}

@end

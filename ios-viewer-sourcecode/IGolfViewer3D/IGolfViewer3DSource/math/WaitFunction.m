//
//  WaitFunction.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "WaitFunction.h"

@interface WaitFunction () {
    BOOL _finished;
    double _currentTime;
}

@end

@implementation WaitFunction

- (BOOL)finished {
    return _finished;
}

- (void)start {

    _currentTime = 0;
    _finished = NO;
}

- (void)tickWithTimeElapsed:(int)timeElapsed {

    if (_finished) {
        return;
    }

    _currentTime += timeElapsed / 1000.0;

    if (_currentTime >= _waitTime) {
        _finished = true;
    }
}

@end

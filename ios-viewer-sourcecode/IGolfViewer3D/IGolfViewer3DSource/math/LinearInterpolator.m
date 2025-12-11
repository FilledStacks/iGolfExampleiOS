//
//  LinearInterpolator.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "LinearInterpolator.h"

@interface LinearInterpolator () {
    double _directionFactor;
    double _currentValue;
    BOOL _finished;
}

@end

@implementation LinearInterpolator

- (double)currentValue {

    return _currentValue;
}

- (BOOL)finished {
    
    if (_startValue == _endValue) {
        return true;
    }
    
    return _finished;
}

- (void)start {
    _currentValue = _startValue;
    _finished = NO;
    _directionFactor = _startValue < _endValue ? 1.0 : -1.0;
}

-(double)completedPercentage {
    
    if (_startValue == _endValue) {
        return 1.0;
    }
    
    if (_directionFactor == 1.0) {
        return (_currentValue - _startValue) / (_endValue - _startValue);
    } else {
        return (_startValue - _currentValue) / (_startValue - _endValue);
    }
}

-(double)valueAtCompletedPercentage:(double)completedPercentage {
    
    if (completedPercentage >= 1.0) {
        return _endValue;
    }
    
    if (_directionFactor == 1.0) {
        
        double diff = _endValue - _startValue;
        double diffCp = diff * completedPercentage;
        double retval = _startValue + diffCp;
        
        return retval;
    } else {
        
        
        double diff = (_startValue - _endValue);
        double diffCp = diff * completedPercentage;
        double retval = _startValue - diffCp;
        
        return retval;
    }
}

- (void)tickWithTimeElapsed:(int)timeElapsed {
    
    if (_finished) {
        return;
    }
    
    _currentValue += timeElapsed / 1000.0 * _speed * _directionFactor;
    
    if ((_directionFactor == 1 && _currentValue > _endValue) || (_directionFactor == -1 && _currentValue < _endValue)) {
        _currentValue = _endValue;
        _finished = true;
    }
}

@end

//
//  RotationHelper.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "RotationHelper.h"
#import <math.h>
@interface RotationHelper () {
    double _endValue;
    double _directionFactor;
    double _currentValue;
}

@end

@implementation RotationHelper

- (id)init {
    self = [super init];
    
    if (self) {
        self->_currentValue = DBL_MIN;
        self->_directionFactor = 0.0;
    }
    
    return self;
}

- (double)endValue {
    return _endValue;
}

- (void)setEndValue:(double)newValue {

    double endValue = [self normalizedAngleWithAngle:newValue];
    

    if (_currentValue == DBL_MIN) {
        _currentValue = endValue;
    } else {
       
        double diff1 = fabs(_currentValue - endValue);
        double diff2 = fabs(_currentValue - (endValue + 360.0));
        double diff3 = fabs((_currentValue + 360.0) - endValue);
        
        if (diff2 < diff1) {
            endValue += 360.0;
        } else if (diff3 < diff1) {
            _currentValue += 360.0;
        }
    }

    _directionFactor = _currentValue < endValue ? 1 : -1;
    _endValue = endValue;
}


- (void)tickWithTimeElapsed:(int)timeElapsed {

    if (_currentValue == _endValue) {
        return;
    }

    double rotationFactor = 1.0 + fabs(_endValue - _currentValue) / 3.0;

    _currentValue += timeElapsed / 1000.0 * _speed * _directionFactor * rotationFactor;
    
    
    if (_directionFactor > 0 && _currentValue > _endValue) {
        
        _currentValue = [self normalizedAngleWithAngle:_currentValue];
    } else if (_directionFactor < 0 && _currentValue < _endValue) {
        
        _currentValue = [self normalizedAngleWithAngle:_currentValue];
    }
    
}


- (double)normalizedAngleWithAngle:(double)angle {
    
    return fmod((angle + 360.0), 360.0);
}

@end

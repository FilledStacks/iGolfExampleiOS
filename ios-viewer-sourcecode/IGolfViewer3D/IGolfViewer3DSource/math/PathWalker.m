//
//  PathWalker.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "PathWalker.h"
#import "../IGolfViewer3DPrivateImports.h"

@interface PathWalker () {
    double _currentTime;
    double _totalLenght;
    NSMutableArray<NSNumber*>* _distanceMarkers;
    BOOL _finished;
    int _nextPointIndex;
    Vector* _position;
    double _angle;
    double _completePercentage;
}

@end

@implementation PathWalker

- (id)init {
    self = [super init];
    
    if (self) {
        self->_distanceMarkers = [NSMutableArray new];
        self->_completePercentage = 0;
    }
    
    return self;
}

- (double)getCompletePercentage {
    return _completePercentage;
}

- (BOOL)finished {
    return _finished;
}

- (Vector*)position {
    return _position;
}

- (double)angle {
    return _angle;
}
- (void)start {
    if (_path.count < 2) {
        _finished = YES;
        return;
    }

    _position = _path[0];
    _currentTime = 0;
    _finished = false;

    _totalLenght = [VectorMath distanceWithVectorArray:_path];

    double currentDistance = 0.0;
    for (int i = 0 ; i < _path.count - 1 ; i++) {
        currentDistance += [_path[i] distanceWithVector:_path[i+1]];
        [_distanceMarkers addObject:@(currentDistance)];
    }

    [self calculatePosition];
    [self calculateAngle];
}

- (void)tickWithTimeElapsed:(int)timeElapsed {
    
    if (_finished) {
        return;
    }

    _currentTime += timeElapsed / 1000.0;

    [self calculatePosition];
    [self calculateAngle];
    
}

- (void)calculatePosition {
    double currentDistance = _currentTime * _speed;

    if (currentDistance > _totalLenght) {
        _finished = YES;
        _position = _path[_path.count - 1];
        _completePercentage = 1;
        return;
    }
    
    _completePercentage = currentDistance / _totalLenght;
    
    int endPoint = 0;
    while ([_distanceMarkers[endPoint] doubleValue] <= currentDistance) {
        endPoint += 1;
    }
    endPoint += 1;

    int startPoint = endPoint - 1;

    double prevDistance = 0.0;
    if (startPoint > 0) {
        prevDistance = [_distanceMarkers[startPoint - 1] doubleValue];
    }
    _position = [[[[_path[endPoint] substractedWithVector:_path[startPoint]] normalized] multipliedWithFactor:currentDistance - prevDistance] addedWithVector:_path[startPoint]];
    _nextPointIndex = endPoint;
}

- (void)calculateAngle {
    if (_finished) {
        return;
    }

    
    _angle = [self calculateAngleWithVector1:[[Vector alloc] initWithX:_position.x andY:_position.y + 1]
                                  andVector2:[[Vector alloc] initWithX:_position.x andY:_position.y]
                                  andVector3:[[Vector alloc] initWithX:_path[_nextPointIndex].x andY:_path[_nextPointIndex].y]];
}

- (double)calculateAngleWithVector1:(Vector*)v1 andVector2:(Vector*)v2 andVector3:(Vector*)v3 {
    double retval = [VectorMath angleWithVector1:v1 andVector2:v2 andVector3:v3];
    retval = [VectorMath rad2degWithRad:retval];

    
    if (v3.x < v2.x) {
        retval *= -1.0;
    }

    return retval;
}

@end

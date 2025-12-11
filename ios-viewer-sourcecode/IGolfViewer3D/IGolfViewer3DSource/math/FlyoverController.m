//
//  FlyoverController.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "FlyoverController.h"
#import "../IGolfViewer3DPrivateImports.h"



@interface FlyoverController () {
    PointListLayer* _centralPath;
    PathWalker* _pathWalker;
    RotationHelper* _rotationHelper;
    LinearInterpolator* _viewInterpolator;
    LinearInterpolator* _zoomInterpolator;
    LinearInterpolator* _zoomSpeedIncreaserInterpolator;
    LinearInterpolator* _zoomSpeedDecreaserInterpolator;
    AnimationState _animationState;
    NSArray<Vector*>* _centralPathForward;
    NSArray<Vector*>* _centralPathReversed;
    double _defaultViewAngle;
    WaitFunction* _waitFunction;
    BOOL _finished;
    ElapsedTimeCalculator* _elapsedTimeCalculator;
    double zooomSpeedIncreasingPercentage;
    double zoomSpeedDecreasingPercentage;
    double zoomSpeedNormalPercentage;
    CentralPathCleaner* _cleaner;
}

@property (nonatomic, readonly) double RotationSpeed;

@end

@implementation FlyoverController

- (double)RotationSpeed {
    return 2.0;
}

- (PointListLayer*)centralPath {
    return _centralPath;
}

-(double)getCompletePercentage {
    return _pathWalker.getCompletePercentage;
}

- (void)setCentralPath:(PointListLayer *)centralPath {
    _centralPath = centralPath;
    NSArray<Vector*>* pointList = [Interpolator interpolateWithCoordinateArray:[_cleaner cleanCentralPath:centralPath.pointList[0].pointList] andPointsPerSegment:10 andCurveType:CatmullRomTypeCentripetal];
    
    _centralPathForward = pointList;
    _centralPathReversed = [NSArray arrayWithArray:[[pointList reverseObjectEnumerator] allObjects]];
}

- (Vector*)position {
    return _pathWalker.position;
}

- (double)rotationAngle {
    return _rotationHelper.currentValue;
}


- (double)viewAngle {

    if (_animationState == AnimationStateTiltGreencenter || _animationState == AnimationStateWaitForFinish) {
        return _viewInterpolator.currentValue;
    }

    return _defaultViewAngle;
}

- (double)zoom {

    if (_animationState == AnimationStateTiltGreencenter || _animationState == AnimationStateWaitForFinish) {
        return _zoomInterpolator.currentValue;
    }
    
    return _defaultZoom;
}

- (BOOL)finished {
    return _finished;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self->_animationState = AnimationStateWait;
        self->_centralPathForward = [NSMutableArray new];
        self->_centralPathReversed = [NSMutableArray new];
        self->_waitFunction = [WaitFunction new];
        ElapsedTimeCalculator *calc = [ElapsedTimeCalculator new];
        [calc resume];
        self->_elapsedTimeCalculator = calc;
        self->_zoomSpeed = 1.0;
        self->zooomSpeedIncreasingPercentage = 0.4;
        self->zoomSpeedDecreasingPercentage = 0.4;
        self->zoomSpeedNormalPercentage = 1 - zoomSpeedDecreasingPercentage - zooomSpeedIncreasingPercentage;
    }
    
    return self;
}


- (void)start {
    _finished = NO;
    [self resume];
    [self flyToGreenCenter];
    [self tick];
}

-(void)testTick {
    
    if (_animationState == AnimationStateFlyToGreencenter) {
        [_pathWalker tickWithTimeElapsed:60];
        
        _rotationHelper.endValue = _pathWalker.angle;
        
        [_rotationHelper tickWithTimeElapsed:60];
        
        if (_pathWalker.finished) {
            _finished = YES;
        }
    }
    
}

- (void)tick {

    if([_elapsedTimeCalculator isPaused] == true) {
        return;
    }
    
    [_elapsedTimeCalculator tick];


    if (_animationState == AnimationStateFlyToGreencenter) {
        
        [_pathWalker tickWithTimeElapsed:_elapsedTimeCalculator.timeElapsedInt];

        if (_pathWalker.finished) {
            [self tiltGreencenter];
            return;
        }
        
        _rotationHelper.endValue = _pathWalker.angle;

        [_rotationHelper tickWithTimeElapsed:_elapsedTimeCalculator.timeElapsedInt];

        
    }


    if (_animationState == AnimationStateTiltGreencenter) {
        
        [_zoomInterpolator tickWithTimeElapsed:_elapsedTimeCalculator.timeElapsedInt];
        
        if (_zoomInterpolator.completedPercentage <= zooomSpeedIncreasingPercentage) {
            
            double cp = _zoomInterpolator.completedPercentage / zooomSpeedIncreasingPercentage;
            _zoomInterpolator.speed = [_zoomSpeedIncreaserInterpolator valueAtCompletedPercentage:cp];
        } else if (_zoomInterpolator.completedPercentage > zooomSpeedIncreasingPercentage && _zoomInterpolator.completedPercentage <= (zoomSpeedDecreasingPercentage + zooomSpeedIncreasingPercentage)) {
           
            double cp = (_zoomInterpolator.completedPercentage - zooomSpeedIncreasingPercentage) / (1 - zooomSpeedIncreasingPercentage - zoomSpeedNormalPercentage);
            _zoomInterpolator.speed = [_zoomSpeedDecreaserInterpolator valueAtCompletedPercentage:cp];
        } else  {
            _zoomInterpolator.speed = 1;
        }
        
        if (_zoomInterpolator.completedPercentage > 0.75) {
             [_viewInterpolator tickWithTimeElapsed:_elapsedTimeCalculator.timeElapsedInt];
        }


        if (_viewInterpolator.finished && _zoomInterpolator.finished) {
            [self waitForFinish];
        }
    }


    if (_animationState == AnimationStateWaitForFinish) {

        [_waitFunction tickWithTimeElapsed:_elapsedTimeCalculator.timeElapsedInt];
        
        if (_waitFunction.finished) {
            _finished = YES;
        }
    }
}

- (double)calculateStartZoomSpeed {
    
    double speed = fabs(_defaultZoom - _endZoom) / 0.96;

    
    if (speed > 2.5) {
        speed = 2.5;
    }
    

    if (speed < 1.0) {
        speed = 1.0;
    }
    
    return fmax(speed , 1.0);
}

- (void)flyToGreenCenter {

    _animationState = AnimationStateFlyToGreencenter;

    _pathWalker = [PathWalker new];
    _pathWalker.path = _centralPathForward;
    _pathWalker.speed = 1.7;

    [_pathWalker start];

    double angle = _pathWalker.angle;
    
    _rotationHelper = [RotationHelper new];
    _rotationHelper.endValue = angle;

    _rotationHelper.speed = self.RotationSpeed;
}

-(void)pause {
    [_elapsedTimeCalculator pause];
}

-(void)resume {
    [_elapsedTimeCalculator resume];
}

- (void)tiltGreencenter {

    _animationState = AnimationStateTiltGreencenter;

    _viewInterpolator = [LinearInterpolator new];
    _viewInterpolator.startValue = _defaultViewAngle;
    _viewInterpolator.endValue = _defaultViewAngle - 10;
    _viewInterpolator.speed = 4.5;

    [_viewInterpolator start];
    
    _zoomSpeedIncreaserInterpolator = [LinearInterpolator new];
    _zoomSpeedIncreaserInterpolator.startValue = 1;
    _zoomSpeedIncreaserInterpolator.endValue = [self calculateStartZoomSpeed];
    _zoomSpeedIncreaserInterpolator.speed = 15;

    [_zoomSpeedIncreaserInterpolator start];
    
    _zoomSpeedDecreaserInterpolator = [LinearInterpolator new];
    _zoomSpeedDecreaserInterpolator.startValue = [self calculateStartZoomSpeed];
    _zoomSpeedDecreaserInterpolator.endValue = 1;
    _zoomSpeedDecreaserInterpolator.speed = 15;
    
    [_zoomSpeedDecreaserInterpolator start];
    
    _zoomInterpolator = [LinearInterpolator new];
    
    _zoomInterpolator.startValue = _defaultZoom;
    _zoomInterpolator.endValue = _endZoom; //_defaultZoom * 0.68;
    _zoomInterpolator.speed = _zoomSpeedIncreaserInterpolator.currentValue;//_zoomSpeed;

    [_zoomInterpolator start];
}

- (void)waitForFinish {

    _animationState = AnimationStateWaitForFinish;

    _waitFunction = [WaitFunction new];
    _waitFunction.waitTime = 3;

    [_waitFunction start];
}

- (AnimationState)getAnimationState {
    return _animationState;
}

-(void)setCleaner:(CentralPathCleaner *)cleaner {
    _cleaner = cleaner;
}

@end

//
//  FlyoverParameters.m
//  iGolfViewer3D
//
//  Copyright (c) 2024. iGolf, Inc. - All Rights Reserved.
//  You may use this code under the terms of the license.
//

#import "FlyoverParameters.h"

#import "../IGolfViewer3DPrivateImports.h"

@interface FlyoverParameters() {
    
    double _defaultZoom;
    double _startViewShift;
    double _endViewShift;
    double _endZoom;
    double _holeAltitude;
    
    Vector* _startPosition;
    Vector* _endPosition;
    
}

@end

@implementation FlyoverParameters

-(id)initWithStartPostion:(Vector*)startPosition endPosition:(Vector*)endPosition defaultZoom:(double)defaultZoom startViewShift:(double)startViewShift endViewShift:(double)endViewShift endZoom:(double)endZoom holeAltitude:(double)holeAltitude {
    self = [super init];
    
    if (self) {
        _startPosition = startPosition;
        _endPosition = endPosition;
        _defaultZoom = defaultZoom;
        _startViewShift = startViewShift;
        _endViewShift = endViewShift;
        _endZoom = endZoom;
        _holeAltitude = holeAltitude;
    }
    
    return self;
}

-(double)holeAltitude{
    return _holeAltitude;
}

-(Vector *)startPosition {
    return _startPosition;
}

-(Vector *)endPosition {
    return _endPosition;
}

-(double)defaultZoom {
    return _defaultZoom;
}

-(double)startViewShift {
    return _startViewShift;
}

-(double)endViewShift {
    return _endViewShift;
}

-(double)endZoom {
    return _endZoom;
}


@end
